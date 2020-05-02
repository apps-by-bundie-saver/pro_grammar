# frozen_string_literal: true

require 'method_source'

class ProGrammar
  class Command
    class Whereami < ProGrammar::ClassCommand
      def initialize(*)
        super

        @method_code = nil
      end

      class << self
        attr_accessor :method_size_cutoff
      end

      @method_size_cutoff = 30

      match 'whereami'
      description 'Show code surrounding the current context.'
      group 'Context'

      banner <<-'BANNER'
        Usage: whereami [-qn] [LINES]

        Describe the current location. If you use `binding.pro_grammar` inside a method then
        whereami will print out the source for that method.

        If a number is passed, then LINES lines before and after the current line will be
        shown instead of the method itself.

        The `-q` flag can be used to suppress error messages in the case that there's
        no code to show. This is used by pro_grammar in the default before_session hook to show
        you when you arrive at a `binding.pro_grammar`.

        The `-n` flag can be used to hide line numbers so that code can be copy/pasted
        effectively.

        When pro_grammar was started on an Object and there is no associated method, whereami
        will instead output a brief description of the current object.
      BANNER

      def setup
        if target.respond_to?(:source_location)
          file, @line = target.source_location
          @file = expand_path(file)
        else
          @file = expand_path(target.eval('__FILE__'))
          @line = target.eval('__LINE__')
        end
        @method = ProGrammar::Method.from_binding(target)
      end

      def options(opt)
        opt.on :q, :quiet, "Don't display anything in case of an error"
        opt.on :n, :"no-line-numbers", "Do not display line numbers"
        opt.on :m, :method, "Show the complete source for the current method."
        opt.on :c, :class, "Show the complete source for the current class or module."
        opt.on :f, :file, "Show the complete source for the current file."
      end

      def code
        @code ||= if opts.present?(:m)
                    method_code || raise(CommandError, "Cannot find method code.")
                  elsif opts.present?(:c)
                    class_code || raise(CommandError, "Cannot find class code.")
                  elsif opts.present?(:f)
                    ProGrammar::Code.from_file(@file)
                  elsif args.any?
                    code_window
                  else
                    default_code
                  end
      end

      def code?
        !!code
      rescue MethodSource::SourceNotFoundError
        false
      end

      def bad_option_combination?
        [opts.present?(:m), opts.present?(:f),
         opts.present?(:c), args.any?].count(true) > 1
      end

      def location
        "#{@file}:#{@line} #{@method && @method.name_with_owner}"
      end

      def process
        if bad_option_combination?
          raise CommandError, "Only one of -m, -c, -f, and  LINES may be specified."
        end

        return if nothing_to_do?

        if internal_binding?(target)
          handle_internal_binding
          return
        end

        set_file_and_dir_locals(@file)

        # pretty_code = code.with_line_numbers(use_line_numbers?)
        #   .with_marker(marker)
        #   .highlighted

        # pro_grammar_instance.pager.page(
        #   "\n#{bold('From:')} #{location}:\n\n" + pretty_code + "\n"
        # )
      end

      private

      def nothing_to_do?
        opts.quiet? && (internal_binding?(target) || !code?)
      end

      def use_line_numbers?
        !opts.present?(:n)
      end

      def marker
        !opts.present?(:n) && @line
      end

      def top_level?
        target_self == ProGrammar.main
      end

      def handle_internal_binding
        if top_level?
          output.puts "At the top level."
        else
          output.puts "Inside #{ProGrammar.view_clip(target_self)}."
        end
      end

      def small_method?
        @method.source_range.count < self.class.method_size_cutoff
      end

      def default_code
        if method_code && small_method?
          method_code
        else
          code_window
        end
      end

      def code_window
        ProGrammar::Code.from_file(@file).around(@line, window_size)
      end

      def method_code
        return @method_code if @method_code

        @method_code = ProGrammar::Code.from_method(@method) if valid_method?
      end

      # This either returns the `target_self`
      # or it returns the class of `target_self` if `target_self` is not a class.
      # @return [ProGrammar::WrappedModule]
      def target_class
        return ProGrammar::WrappedModule(target_self) if target_self.is_a?(Module)

        ProGrammar::WrappedModule(target_self.class)
      end

      def class_code
        @class_code ||=
          begin
            mod = @method ? ProGrammar::WrappedModule(@method.owner) : target_class
            idx = mod.candidates.find_index { |v| expand_path(v.source_file) == @file }
            idx && ProGrammar::Code.from_module(mod, idx)
          end
      end

      def valid_method?
        @method && @method.source? && expand_path(@method.source_file) == @file &&
          @method.source_range.include?(@line)
      end

      def expand_path(filename)
        return unless filename
        return filename if ProGrammar.eval_path == filename

        File.expand_path(filename)
      end

      def window_size
        pro_grammar_instance.end_trace unless pro_grammar_instance.end_trace.nil?
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Whereami)
    ProGrammar::Commands.alias_command '@', 'whereami'
    ProGrammar::Commands.alias_command(/whereami[!?]+/, 'whereami')
  end
end
