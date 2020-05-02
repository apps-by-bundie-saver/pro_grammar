# frozen_string_literal: true

require 'stringio'

class ProGrammar
  # Manage the processing of command line options
  class CLI
    NoOptionsError = Class.new(StandardError)

    class << self
      # @return [Proc] The Proc defining the valid command line options.
      attr_accessor :options

      # @return [Array] The Procs that process the parsed options. Plugins can
      #   utilize this facility in order to add and process their own ProGrammar
      #   options.
      attr_accessor :option_processors

      # @return [Array<String>] The input array of strings to process
      #   as CLI options.
      attr_accessor :input_args

      # Add another set of CLI options (a ProGrammar::Slop block)
      def add_options(&block)
        if options
          old_options = options
          self.options = proc do
            instance_exec(&old_options)
            instance_exec(&block)
          end
        else
          self.options = block
        end

        self
      end

      # Bring in options defined in plugins
      def add_plugin_options
        ProGrammar.plugins.values.each(&:load_cli_options)

        self
      end

      # Add a block responsible for processing parsed options.
      def add_option_processor(&block)
        self.option_processors ||= []
        option_processors << block

        self
      end

      # Clear `options` and `option_processors`
      def reset
        self.options           = nil
        self.option_processors = nil
      end

      def parse_options(args = ARGV)
        unless options
          raise NoOptionsError,
                "No command line options defined! Use ProGrammar::CLI.add_options to " \
                "add command line options."
        end

        @pass_argv = args.index { |cli_arg| %w[- --].include?(cli_arg) }
        if @pass_argv
          slop_args = args[0...@pass_argv]
          self.input_args = args.replace(args[@pass_argv + 1..-1])
        else
          self.input_args = slop_args = args
        end

        begin
          opts = ProGrammar::Slop.parse!(
            slop_args,
            help: true,
            multiple_switches: false,
            strict: true,
            &options
          )
        rescue ProGrammar::Slop::InvalidOptionError
          # Display help message on unknown switches and exit.
          puts ProGrammar::Slop.new(&options)
          Kernel.exit
        end

        ProGrammar.initial_session_setup
        ProGrammar.final_session_setup

        # Option processors are optional.
        option_processors.each { |processor| processor.call(opts) } if option_processors

        opts
      end

      def start(opts)
        Kernel.exit if opts.help?

        # invoked via cli
        ProGrammar.cli = true

        # create the actual context
        if opts[:context]
          ProGrammar.initial_session_setup
          context = ProGrammar.binding_for(eval(opts[:context])) # rubocop:disable Security/Eval
          ProGrammar.final_session_setup
        else
          context = ProGrammar.toplevel_binding
        end

        if !@pass_argv && ProGrammar::CLI.input_args.any? && ProGrammar::CLI.input_args != ["pro_grammar"]
          full_name = File.expand_path(ProGrammar::CLI.input_args.first)
          ProGrammar.load_file_through_repl(full_name)
          Kernel.exit
        end

        # Start the session (running any code passed with -e, if there is any)
        ProGrammar.start(context, input: StringIO.new(ProGrammar.config.exec_string))
      end
    end

    reset
  end
end

# Bring in options defined by plugins
ProGrammar::Slop.new do
  on "no-plugins" do
    ProGrammar.config.should_load_plugins = false
  end
end.parse(ARGV.dup)

ProGrammar::CLI.add_plugin_options if ProGrammar.config.should_load_plugins

# The default ProGrammar command line options (before plugin options are included)
ProGrammar::CLI.add_options do
  banner(
    "Usage: pro_grammar [OPTIONS]\n" \
    "Start a ProGrammar session.\n" \
    "See http://pro_grammarrepl.org/ for more information.\n" \
    "Copyright (c) 2016 John Mair (banisterfiend)" \
  )

  on(
    :e, :exec=, "A line of code to execute in context before the session starts"
  ) do |input|
    ProGrammar.config.exec_string += "\n" unless ProGrammar.config.exec_string.empty?
    ProGrammar.config.exec_string += input
  end

  on "no-pager", "Disable pager for long output" do
    ProGrammar.config.pager = false
  end

  on "no-history", "Disable history loading" do
    ProGrammar.config.history.should_load = false
  end

  on "no-color", "Disable syntax highlighting for session" do
    ProGrammar.config.color = false
  end

  on :f, "Suppress loading of pro_grammarrc" do
    ProGrammar.config.should_load_rc = false
    ProGrammar.config.should_load_local_rc = false
  end

  on :s, "select-plugin=", "Only load specified plugin (and no others)." do |plugin_name|
    ProGrammar.config.should_load_plugins = false
    ProGrammar.plugins[plugin_name].activate!
  end

  on :d, "disable-plugin=", "Disable a specific plugin." do |plugin_name|
    ProGrammar.plugins[plugin_name].disable!
  end

  on "no-plugins", "Suppress loading of plugins." do
    ProGrammar.config.should_load_plugins = false
  end

  on "plugins", "List installed plugins." do
    puts "Installed Plugins:"
    puts "--"
    ProGrammar.locate_plugins.each do |plugin|
      puts plugin.name.to_s.ljust(18) << plugin.spec.summary
    end
    Kernel.exit
  end

  on "simple-prompt", "Enable simple prompt mode" do
    ProGrammar.config.prompt = ProGrammar::Prompt[:simple]
  end

  on "noprompt", "No prompt mode" do
    ProGrammar.config.prompt = ProGrammar::Prompt[:none]
  end

  on :r, :require=, "`require` a Ruby script at startup" do |file|
    ProGrammar.config.requires << file
  end

  on(:I=, "Add a path to the $LOAD_PATH", as: Array, delimiter: ":") do |load_path|
    load_path.map! do |path|
      %r{\A\./} =~ path ? path : File.expand_path(path)
    end

    $LOAD_PATH.unshift(*load_path)
  end

  on "gem", "Shorthand for -I./lib -rgemname" do |_load_path|
    $LOAD_PATH.unshift("./lib")
    Dir["./lib/*.rb"].each do |file|
      ProGrammar.config.requires << file
    end
  end

  on :v, :version, "Display the ProGrammar version" do
    puts "ProGrammar version #{ProGrammar::VERSION} on Ruby #{RUBY_VERSION}"
    Kernel.exit
  end

  on :c, :context=,
     "Start the session in the specified context. Equivalent to " \
     "`context.pro_grammar` in a session.",
     default: "ProGrammar.toplevel_binding"
end
