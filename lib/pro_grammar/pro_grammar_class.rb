# frozen_string_literal: true

require 'stringio'
require 'pathname'

require 'pry'

class ProGrammar
  LOCAL_RC_FILE = "./.pro_grammarrc".freeze

  # @return [Boolean] true if this Ruby supports safe levels and tainting,
  #  to guard against using deprecated or unsupported features
  HAS_SAFE_LEVEL = (
    RUBY_ENGINE == 'ruby' &&
    Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7')
  )

  class << self
    extend ProGrammar::Forwardable
    attr_accessor :custom_completions
    attr_accessor :current_line
    attr_accessor :line_buffer
    attr_accessor :eval_path
    attr_accessor :cli
    attr_accessor :quiet
    attr_accessor :last_internal_error
    attr_accessor :config

    def_delegators :@plugin_manager, :plugins, :load_plugins, :locate_plugins

    def_delegators(
      :@config, :input, :input=, :output, :output=, :commands,
      :commands=, :print, :print=, :exception_handler, :exception_handler=,
      :hooks, :hooks=, :color, :color=, :pager, :pager=, :editor, :editor=,
      :memory_size, :memory_size=, :extra_sticky_locals, :extra_sticky_locals=,
      :prompt, :prompt=, :history, :history=
    )

    #
    # @example
    #  ProGrammar.configure do |config|
    #     config.eager_load! # optional
    #     config.input =     # ..
    #     config.foo = 2
    #  end
    #
    # @yield [config]
    #   Yields a block with {ProGrammar.config} as its argument.
    #
    def configure
      yield config
    end
  end

  #
  # @return [main]
  #   returns the special instance of Object, "main".
  #
  def self.main
    @main ||= TOPLEVEL_BINDING.eval "self"
  end

  #
  # @return [ProGrammar::Config]
  #  Returns a value store for an instance of ProGrammar running on the current thread.
  #
  def self.current
    Thread.current[:__pro_grammar__] ||= {}
  end

  #
  # @return [ProGrammar::Tracer]
  # Returns a ProGrammar::Tracer instance
  def self.start_trace
    $pro_grammar = {
      start_trace: ProGrammar::Tracer.new(:start_trace, caller.first.split(":")[1].to_i),
      end_trace: nil,
      note_formatter: ProGrammar::NoteFormatter.new,
      attempts: ProGrammar::Attempts.new,
      display: ProGrammar::Display.new,
      note_storage_path: nil,
      current_note: nil,
    }
    
    $pro_grammar[:note_formatter].header[:filename] = caller[0][/[^:]+/]
    $pro_grammar[:note_formatter].header[:start_line] = caller.first.split(":")[1].to_i
    end_trace_found = false
    line_num = 1
    file = File.open($pro_grammar[:note_formatter].header[:filename]).read

    file.each_line do |line|
      unless end_trace_found
        code_block = line.strip
        if !end_trace_found && code_block =~ /^ProGrammar.end_trace/
          $pro_grammar[:end_trace] = ProGrammar::Tracer.new(:end_trace, line_num.to_i)
          $pro_grammar[:note_formatter].footer[:end_line] = line_num.to_i
          end_trace_found = true
        elsif !end_trace_found && line_num > $pro_grammar[:start_trace].line_number
          $pro_grammar[:note_formatter].header[:code_lines] << [line, line_num]
        end
        line_num += 1
      end
    end

    if end_trace_found
        $pro_grammar[:display].new_note
    else
      raise StandardError.new "Missing 'ProGrammar.end_trace'. Please set a 'end_trace' with ProGrammar#end_trace."
    end
  end

  #
  # @return [ProGrammar::Tracer]
  # Returns a ProGrammar::Tracer instance
  def self.end_trace
    @end_trace = ProGrammar::Tracer.new(:end_trace, caller.first.split(":")[1].to_i)
  end

  # Load the given file in the context of `ProGrammar.toplevel_binding`
  # @param [String] file The unexpanded file path.
  def self.load_file_at_toplevel(file)
    toplevel_binding.eval(File.read(file), file)
  rescue RescuableException => e
    puts "Error loading #{file}: #{e}\n#{e.backtrace.first}"
  end

  # Load RC files if appropriate This method can also be used to reload the
  # files if they have changed.
  def self.load_rc_files
    rc_files_to_load.each do |file|
      critical_section do
        load_file_at_toplevel(file)
      end
    end
  end

  # Load the local RC file (./.pro_grammarrc)
  def self.rc_files_to_load
    files = []
    files << ProGrammar.config.rc_file if ProGrammar.config.should_load_rc
    files << LOCAL_RC_FILE if ProGrammar.config.should_load_local_rc
    files.map { |file| real_path_to(file) }.compact.uniq
  end

  # Expand a file to its canonical name (following symlinks as appropriate)
  def self.real_path_to(file)
    Pathname.new(File.expand_path(file)).realpath.to_s
  rescue Errno::ENOENT, Errno::EACCES
    nil
  end

  # Load any Ruby files specified with the -r flag on the command line.
  def self.load_requires
    ProGrammar.config.requires.each do |file|
      require file
    end
  end

  # Trap interrupts on jruby, and make them behave like MRI so we can
  # catch them.
  def self.load_traps
    trap('INT') { raise Interrupt }
  end

  def self.load_win32console
    require 'win32console'
    # The mswin and mingw versions of pro_grammar require win32console, so this should
    # only fail on jruby (where win32console doesn't work).
    # Instead we'll recommend ansicon, which does.
  rescue LoadError
    warn <<-WARNING if ProGrammar.config.windows_console_warning
For a better ProGrammar experience on Windows, please use ansicon:
  https://github.com/adoxa/ansicon
If you use an alternative to ansicon and don't want to see this warning again,
you can add "ProGrammar.config.windows_console_warning = false" to your pro_grammarrc.
    WARNING
  end

  # Do basic setup for initial session including: loading pro_grammarrc, plugins,
  # requires, and history.
  def self.initial_session_setup
    return unless initial_session?

    @initial_session = false

    # note these have to be loaded here rather than in _pro_grammar_ as
    # we only want them loaded once per entire ProGrammar lifetime.
    load_rc_files
  end

  def self.final_session_setup
    return if @session_finalized

    @session_finalized = true
    load_plugins if ProGrammar.config.should_load_plugins
    load_requires if ProGrammar.config.should_load_requires
    load_history if ProGrammar.config.history_load
    load_traps if ProGrammar.config.should_trap_interrupts
    load_win32console if Helpers::Platform.windows? && !Helpers::Platform.windows_ansi?
  end

  # Start a ProGrammar REPL.
  # This method also loads `pro_grammarrc` as necessary the first time it is invoked.
  # @param [Object, Binding] target The receiver of the ProGrammar session
  # @param [Hash] options
  # @option options (see ProGrammar#initialize)
  # @example
  #   ProGrammar.start(Object.new, :input => MyInput.new)
  def self.start(target = nil, options = {}, filename, start_trace_line_number, end_trace_line_number)
    return if ProGrammar::Env['DISABLE_PRY']
    if ProGrammar::Env['FAIL_PRY']
      raise 'You have FAIL_PRY set to true, which results in ProGrammar calls failing'
    end

    options = options.to_hash

    if in_critical_section?
      output.puts "ERROR: ProGrammar started inside ProGrammar."
      output.puts "This can happen if you have a binding.pro_grammar inside a #to_s " \
                  "or #inspect function."
      return
    end

    options[:target] = ProGrammar.binding_for(target || toplevel_binding)
    initial_session_setup
    final_session_setup

    # Unless we were given a backtrace, save the current one
    if options[:backtrace].nil?
      options[:backtrace] = caller

      # If ProGrammar was started via `binding.pro_grammar`, elide that from the backtrace
      if options[:backtrace].first =~ /pro_grammar.*core_extensions.*pro_grammar/
        options[:backtrace].shift
      end
    end

    driver = options[:driver] || ProGrammar::REPL

    # Enter the matrix
    driver.start(options, filename, start_trace_line_number, end_trace_line_number)
  rescue ProGrammar::TooSafeException
    puts "ERROR: ProGrammar cannot work with $SAFE > 0"
    raise
  end

  # Execute the file through the REPL loop, non-interactively.
  # @param [String] file_name File name to load through the REPL.
  def self.load_file_through_repl(file_name)
    REPLFileLoader.new(file_name).load
  end

  #
  # An inspector that clips the output to `max_length` chars.
  # In case of > `max_length` chars the `#<Object...> notation is used.
  #
  # @param [Object] obj
  #   The object to view.
  #
  # @param [Hash] options
  # @option options [Integer] :max_length (60)
  #   The maximum number of chars before clipping occurs.
  #
  # @option options [Boolean] :id (false)
  #   Boolean to indicate whether or not a hex reprsentation of the object ID
  #   is attached to the return value when the length of inspect is greater than
  #   value of `:max_length`.
  #
  # @return [String]
  #   The string representation of `obj`.
  #
  def self.view_clip(obj, options = {})
    max = options.fetch :max_length, 60
    id = options.fetch :id, false
    if obj.is_a?(Module) && obj.name.to_s != "" && obj.name.to_s.length <= max
      obj.name.to_s
    elsif ProGrammar.main == obj
      # Special-case to support jruby. Fixed as of:
      # https://github.com/jruby/jruby/commit/d365ebd309cf9df3dde28f5eb36ea97056e0c039
      # we can drop in the future.
      obj.to_s
      # rubocop:disable Style/CaseEquality
    elsif ProGrammar.config.prompt_safe_contexts.any? { |v| v === obj } &&
          obj.inspect.length <= max
      # rubocop:enable Style/CaseEquality

      obj.inspect
    elsif id
      format("#<#{obj.class}:0x%<id>x>", id: obj.object_id << 1)
    else
      "#<#{obj.class}>"
    end
  rescue RescuableException
    "unknown"
  end

  # Load Readline history if required.
  def self.load_history
    ProGrammar.history.load
  end

  # @return [Boolean] Whether this is the first time a ProGrammar session has
  #   been started since loading the ProGrammar class.
  def self.initial_session?
    @initial_session
  end

  # Run a ProGrammar command from outside a session. The commands available are
  # those referenced by `ProGrammar.config.commands` (the default command set).
  # @param [String] command_string The ProGrammar command (including arguments,
  #   if any).
  # @param [Hash] options Optional named parameters.
  # @return [nil]
  # @option options [Object, Binding] :target The object to run the
  #   command under. Defaults to `TOPLEVEL_BINDING` (main).
  # @option options [Boolean] :show_output Whether to show command
  #   output. Defaults to true.
  # @example Run at top-level with no output.
  #   ProGrammar.run_command "ls"
  # @example Run under ProGrammar class, returning only public methods.
  #   ProGrammar.run_command "ls -m", :target => ProGrammar
  # @example Display command output.
  #   ProGrammar.run_command "ls -av", :show_output => true
  def self.run_command(command_string, options = {})
    options = {
      target: TOPLEVEL_BINDING,
      show_output: true,
      output: ProGrammar.config.output,
      commands: ProGrammar.config.commands
    }.merge!(options)

    # :context for compatibility with <= 0.9.11.4
    target = options[:context] || options[:target]
    output = options[:show_output] ? options[:output] : StringIO.new

    pro_grammar = ProGrammar.new(output: output, target: target, commands: options[:commands])
    pro_grammar.eval command_string
    nil
  end

  def self.auto_resize!
    ProGrammar.config.input # by default, load Readline

    if !defined?(Readline) || ProGrammar.config.input != Readline
      warn "Sorry, you must be using Readline for ProGrammar.auto_resize! to work."
      return
    end

    if Readline::VERSION =~ /edit/i
      warn(<<-WARN)
Readline version #{Readline::VERSION} detected - will not auto_resize! correctly.
  For the fix, use GNU Readline instead:
  https://github.com/guard/guard/wiki/Add-Readline-support-to-Ruby-on-Mac-OS-X
      WARN
      return
    end

    trap :WINCH do
      begin
        Readline.set_screen_size(*output.size)
      rescue StandardError => e
        warn "\nProGrammar.auto_resize!'s Readline.set_screen_size failed: #{e}"
      end
      begin
        Readline.refresh_line
      rescue StandardError => e
        warn "\nProGrammar.auto_resize!'s Readline.refresh_line failed: #{e}"
      end
    end
  end

  # Set all the configurable options back to their default values
  def self.reset_defaults
    @initial_session = true
    @session_finalized = nil

    self.config = ProGrammar::Config.new
    self.cli = false
    self.current_line = 1
    self.line_buffer = [""]
    self.eval_path = "(pro_grammar)"
  end

  # Basic initialization.
  def self.init
    @plugin_manager ||= PluginManager.new
    reset_defaults
    locate_plugins
  end

  # Return a `Binding` object for `target` or return `target` if it is
  # already a `Binding`.
  # In the case where `target` is top-level then return `TOPLEVEL_BINDING`
  # @param [Object] target The object to get a `Binding` object for.
  # @return [Binding] The `Binding` object.
  def self.binding_for(target)
    return target if Binding === target # rubocop:disable Style/CaseEquality
    return TOPLEVEL_BINDING if ProGrammar.main == target

    target.__binding__
  end

  def self.toplevel_binding
    unless defined?(@toplevel_binding) && @toplevel_binding
      # Grab a copy of the TOPLEVEL_BINDING without any local variables.
      # This binding has a default definee of Object, and new methods are
      # private (just as in TOPLEVEL_BINDING).
      TOPLEVEL_BINDING.eval <<-RUBY
        def self.__pro_grammar__
          binding
        end
        ProGrammar.toplevel_binding = __pro_grammar__
        class << self; undef __pro_grammar__; end
      RUBY
    end
    @toplevel_binding.eval('private')
    @toplevel_binding
  end

  class << self
    attr_writer :toplevel_binding
  end

  def self.in_critical_section?
    Thread.current[:pro_grammar_critical_section] ||= 0
    Thread.current[:pro_grammar_critical_section] > 0
  end

  def self.critical_section
    Thread.current[:pro_grammar_critical_section] ||= 0
    Thread.current[:pro_grammar_critical_section] += 1
    yield
  ensure
    Thread.current[:pro_grammar_critical_section] -= 1
  end
end

ProGrammar.init
