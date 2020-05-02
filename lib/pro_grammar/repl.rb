# frozen_string_literal: true

class ProGrammar
  class REPL
    extend ProGrammar::Forwardable
    def_delegators :@pro_grammar, :input, :output

    # @return [ProGrammar] The instance of {ProGrammar} that the user is controlling.
    attr_accessor :pro_grammar

    # Instantiate a new {ProGrammar} instance with the given options, then start a
    # {REPL} instance wrapping it.
    # @option options See {ProGrammar#initialize}
    def self.start(options, filename, start_trace_line_number, end_trace_line_number)
      new(ProGrammar.new(options), filename, start_trace_line_number, end_trace_line_number).start
    end

    # Create an instance of {REPL} wrapping the given {ProGrammar}.
    # @param [ProGrammar] pro_grammar The instance of {ProGrammar} that this {REPL} will control.
    # @param [Hash] options Options for this {REPL} instance.
    # @option options [Object] :target The initial target of the session.
    def initialize(pro_grammar, options = {}, filename, start_trace_line_number, end_trace_line_number)
      @pro_grammar    = pro_grammar
      @pro_grammar.filename = filename
      @pro_grammar.start_trace = start_trace_line_number
      @pro_grammar.end_trace = end_trace_line_number

      @indent = ProGrammar::Indent.new(pro_grammar)

      @readline_output = nil

      @pro_grammar.push_binding options[:target] if options[:target]
    end

    # Start the read-eval-print loop.
    # @return [Object?] If the session throws `:breakout`, return the value
    #   thrown with it.
    # @raise [Exception] If the session throws `:raise_up`, raise the exception
    #   thrown with it.
    def start
      prologue
      file_code = ProGrammar::Code.from_file(@pro_grammar.filename)
      start_trace = nil
      end_trace = nil
      file_code.lines.each_with_index do |line, index|
        if line.strip.match(/^binding.pro_grammar_start$/)
          start_trace = index
        elsif line.strip.match(/^binding.pro_grammar_end$/)
          end_trace = index
          break
        end
      end
      code = file_code.lines.select.with_index do |line, index|
        if index > start_trace && index < end_trace
          line
        end
      end
      line_number = start_trace + 1
      code.each_with_index do |line, index|
        line_number = start_trace + index
        begin
          @pro_grammar.eval(line, line_number)
        rescue Exception => e
          ProGrammar::ExceptionHandler.determine_marker_lineno_where_exception(e.class, e, line_number, self)
        end
      end

      # ProGrammar::InputLock.for(:all).with_ownership { repl }
    ensure
      epilogue
    end

    private

    # Set up the repl session.
    # @return [void]
    def prologue
      pro_grammar.exec_hook :before_session, pro_grammar.output, pro_grammar.current_binding, pro_grammar

      return unless pro_grammar.config.correct_indent

      # Clear the line before starting ProGrammar. This fixes issue #566.
      output.print(Helpers::Platform.windows_ansi? ? "\e[0F" : "\e[0G")
    end

    # The actual read-eval-print loop.
    #
    # The {REPL} instance is responsible for reading and looping, whereas the
    # {ProGrammar} instance is responsible for evaluating user input and printing
    # return values and command output.
    #
    # @return [Object?] If the session throws `:breakout`, return the value
    #   thrown with it.
    # @raise [Exception] If the session throws `:raise_up`, raise the exception
    #   thrown with it.
    def repl
      loop do
        case val = read
        when :control_c
          output.puts ""
          pro_grammar.reset_eval_string
        when :no_more_input
          output.puts "" if output.tty?
          break
        else
          output.puts "" if val.nil? && output.tty?
          return pro_grammar.exit_value unless pro_grammar.eval(val)
        end
      end
    end

    # Clean up after the repl session.
    # @return [void]
    def epilogue
      pro_grammar.exec_hook :after_session, pro_grammar.output, pro_grammar.current_binding, pro_grammar
    end

    # Read a line of input from the user.
    # @return [String] The line entered by the user.
    # @return [nil] On `<Ctrl-D>`.
    # @return [:control_c] On `<Ctrl+C>`.
    # @return [:no_more_input] On EOF.
    def read
      @indent.reset if pro_grammar.eval_string.empty?
      current_prompt = pro_grammar.select_prompt
      indentation = pro_grammar.config.auto_indent ? @indent.current_prefix : ''

      val = read_line("#{current_prompt}#{indentation}")

      # Return nil for EOF, :no_more_input for error, or :control_c for <Ctrl-C>
      return val unless val.is_a?(String)

      if pro_grammar.config.auto_indent
        original_val = "#{indentation}#{val}"
        indented_val = @indent.indent(val)

        if output.tty? &&
           pro_grammar.config.correct_indent &&
           ProGrammar::Helpers::BaseHelpers.use_ansi_codes?
          output.print @indent.correct_indentation(
            current_prompt,
            indented_val,
            calculate_overhang(current_prompt, original_val, indented_val)
          )
          output.flush
        end
      else
        indented_val = val
      end

      indented_val
    end

    # Manage switching of input objects on encountering `EOFError`s.
    # @return [Object] Whatever the given block returns.
    # @return [:no_more_input] Indicates that no more input can be read.
    def handle_read_errors
      should_retry = true
      exception_count = 0

      begin
        yield
      rescue EOFError
        pro_grammar.config.input = ProGrammar.config.input
        unless should_retry
          output.puts "Error: ProGrammar ran out of things to read from! " \
            "Attempting to break out of REPL."
          return :no_more_input
        end
        should_retry = false
        retry

      # Handle <Ctrl+C> like Bash: empty the current input buffer, but don't
      # quit.  This is only for MRI 1.9; other versions of Ruby don't let you
      # send Interrupt from within Readline.
      rescue Interrupt
        return :control_c

      # If we get a random error when trying to read a line we don't want to
      # automatically retry, as the user will see a lot of error messages
      # scroll past and be unable to do anything about it.
      rescue RescuableException => e
        puts "Error: #{e.message}"
        output.puts e.backtrace
        exception_count += 1
        retry if exception_count < 5
        puts "FATAL: ProGrammar failed to get user input using `#{input}`."
        puts "To fix this you may be able to pass input and output file " \
          "descriptors to pro_grammar directly. e.g."
        puts "  ProGrammar.config.input = STDIN"
        puts "  ProGrammar.config.output = STDOUT"
        puts "  binding.pro_grammar"
        return :no_more_input
      end
    end

    # Returns the next line of input to be sent to the {ProGrammar} instance.
    # @param [String] current_prompt The prompt to use for input.
    # @return [String?] The next line of input, or `nil` on <Ctrl-D>.
    def read_line(current_prompt)
      handle_read_errors do
        if coolline_available?
          input.completion_proc = proc do |cool|
            completions = @pro_grammar.complete cool.completed_word
            completions.compact
          end
        elsif input.respond_to? :completion_proc=
          input.completion_proc = proc do |inp|
            @pro_grammar.complete inp
          end
        end

        if readline_available?
          set_readline_output
          input_readline(current_prompt, false) # false since we'll add it manually
        elsif coolline_available?
          input_readline(current_prompt)
        elsif input.method(:readline).arity == 1
          input_readline(current_prompt)
        else
          input_readline
        end
      end
    end

    def input_readline(*args)
      ProGrammar::InputLock.for(:all).interruptible_region do
        input.readline(*args)
      end
    end

    def readline_available?
      defined?(Readline) && input == Readline
    end

    def coolline_available?
      defined?(Coolline) && input.is_a?(Coolline)
    end

    # If `$stdout` is not a tty, it's probably a pipe.
    # @example
    #   # `piping?` returns `false`
    #   % pro_grammar
    #   [1] pro_grammar(main)
    #
    #   # `piping?` returns `true`
    #   % pro_grammar | tee log
    def piping?
      return false unless $stdout.respond_to?(:tty?)

      !$stdout.tty? && $stdin.tty? && !Helpers::Platform.windows?
    end

    # @return [void]
    def set_readline_output
      return if @readline_output

      @readline_output = (Readline.output = ProGrammar.config.output) if piping?
    end

    # Calculates correct overhang for current line. Supports vi Readline
    # mode and its indicators such as "(ins)" or "(cmd)".
    #
    # @return [Integer]
    # @note This doesn't calculate overhang for Readline's emacs mode with an
    #   indicator because emacs is the default mode and it doesn't use
    #   indicators in 99% of cases.
    def calculate_overhang(current_prompt, original_val, indented_val)
      overhang = original_val.length - indented_val.length

      if readline_available? && Readline.respond_to?(:vi_editing_mode?)
        begin
          # rb-readline doesn't support this method:
          # https://github.com/ConnorAtherton/rb-readline/issues/152
          if Readline.vi_editing_mode?
            overhang = output.width - current_prompt.size - indented_val.size
          end
        rescue NotImplementedError
          # VI editing mode is unsupported on JRuby.
          # https://github.com/pro_grammar/pro_grammar/issues/1840
          nil
        end
      end
      [0, overhang].max
    end
  end
end
