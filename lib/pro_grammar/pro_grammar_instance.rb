# frozen_string_literal: true

require 'method_source'
require 'ostruct'

##
# ProGrammar is a powerful alternative to the standard IRB shell for Ruby. It
# features syntax highlighting, a flexible plugin architecture, runtime
# invocation and source and documentation browsing.
#
# ProGrammar can be started similar to other command line utilities by simply running
# the following command:
#
#     pro_grammar
#
# Once inside ProGrammar you can invoke the help message:
#
#     help
#
# This will show a list of available commands and their usage. For more
# information about ProGrammar you can refer to the following resources:
#
# * http://pro_grammarrepl.org/
# * https://github.com/pro_grammar/pro_grammar
# * the IRC channel, which is #pro_grammar on the Freenode network
#

# rubocop:disable Metrics/ClassLength
class ProGrammar
  extend ProGrammar::Forwardable

  attr_accessor :binding_stack
  attr_accessor :custom_completions
  attr_accessor :eval_string
  attr_accessor :backtrace
  attr_accessor :suppress_output
  attr_accessor :last_result
  attr_accessor :last_file
  attr_accessor :last_dir
  attr_accessor :engine
  attr_accessor :display
  attr_accessor :author
  attr_accessor :filename
  attr_accessor :start_trace
  attr_accessor :end_trace
  attr_accessor :attempts
  attr_accessor :error
  attr_accessor :note_storage_path
  attr_accessor :notes
  attr_accessor :current_note

  attr_reader :last_exception
  attr_reader :exit_value

  # @since v0.12.0
  attr_reader :input_ring

  # @since v0.12.0
  attr_reader :output_ring

  attr_reader :config


  def_delegators(
    :@config, :input, :input=, :output, :output=, :commands,
    :commands=, :print, :print=, :exception_handler, :exception_handler=,
    :hooks, :hooks=, :color, :color=, :pager, :pager=, :editor, :editor=,
    :memory_size, :memory_size=, :extra_sticky_locals, :extra_sticky_locals=
  )

  EMPTY_COMPLETIONS = [].freeze

  # Create a new {ProGrammar} instance.
  # @param [Hash] options
  # @option options [#readline] :input
  #   The object to use for input.
  # @option options [#puts] :output
  #   The object to use for output.
  # @option options [ProGrammar::CommandBase] :commands
  #   The object to use for commands.
  # @option options [Hash] :hooks
  #   The defined hook Procs.
  # @option options [ProGrammar::Prompt] :prompt
  #   The array of Procs to use for prompts.
  # @option options [Proc] :print
  #   The Proc to use for printing return values.
  # @option options [Boolean] :quiet
  #   Omit the `whereami` banner when starting.
  # @option options [Array<String>] :backtrace
  #   The backtrace of the session's `binding.pro_grammar` line, if applicable.
  # @option options [Object] :target
  #   The initial context for this session.
  def initialize(options = {})
    @binding_stack = []
    @indent        = ProGrammar::Indent.new(self)
    @eval_string   = ''.dup
    @backtrace     = options.delete(:backtrace) || caller
    target = options.delete(:target)
    @config = self.class.config.merge(options)
    push_prompt(config.prompt)
    @input_ring = ProGrammar::Ring.new(config.memory_size)
    @output_ring = ProGrammar::Ring.new(config.memory_size)
    @custom_completions = config.command_completions
    set_last_result nil
    @input_ring << nil
    push_initial_binding(target)
    exec_hook(:when_started, target, options, self)
    @prompt_warn = false
    @engine = ProGrammar::Engine.new(self)
    @display = ProGrammar::Display.new(self)
    @author = nil
    @filename = nil
    @start_trace = nil
    @end_trace = nil
    @attempts = []
    @error = nil
    @note_storage_path = nil
    @current_note = ProGrammar::Note.new
    @notes = [@current_note]
  end

  # This is the prompt at the top of the prompt stack.
  # @return [ProGrammar::Prompt] the current prompt
  def prompt
    prompt_stack.last
  end

  # Sets the ProGrammar prompt.
  # @param [ProGrammar::Prompt] new_prompt
  # @return [void]
  def prompt=(new_prompt)
    if prompt_stack.empty?
      push_prompt new_prompt
    else
      prompt_stack[-1] = new_prompt
    end
  end

  # Initialize this instance by pushing its initial context into the binding
  # stack. If no target is given, start at the top level.
  def push_initial_binding(target = nil)
    push_binding(target || ProGrammar.toplevel_binding)
  end

  # The currently active `Binding`.
  # @return [Binding] The currently active `Binding` for the session.
  def current_binding
    binding_stack.last
  end
  alias current_context current_binding # support previous API

  # Push a binding for the given object onto the stack. If this instance is
  # currently stopped, mark it as usable again.
  def push_binding(object)
    @stopped = false
    binding_stack << ProGrammar.binding_for(object)
  end

  #
  # Generate completions.
  #
  # @param [String] str
  #   What the user has typed so far
  #
  # @return [Array<String>]
  #   Possible completions
  #
  def complete(str)
    return EMPTY_COMPLETIONS unless config.completer

    ProGrammar.critical_section do
      completer = config.completer.new(config.input, self)
      completer.call(
        str,
        target: current_binding,
        custom_completions: custom_completions.call.push(*sticky_locals.keys)
      )
    end
  end

  #
  # Injects a local variable into the provided binding.
  #
  # @param [String] name
  #   The name of the local to inject.
  #
  # @param [Object] value
  #   The value to set the local to.
  #
  # @param [Binding] binding
  #   The binding to set the local on.
  #
  # @return [Object]
  #   The value the local was set to.
  #
  def inject_local(name, value, binding)
    value = value.is_a?(Proc) ? value.call : value
    if binding.respond_to?(:local_variable_set)
      binding.local_variable_set name, value
    else # < 2.1
      begin
        ProGrammar.current[:pro_grammar_local] = value
        binding.eval "#{name} = ::ProGrammar.current[:pro_grammar_local]"
      ensure
        ProGrammar.current[:pro_grammar_local] = nil
      end
    end
  end

  undef :memory_size if method_defined? :memory_size
  # @return [Integer] The maximum amount of objects remembered by the inp and
  #   out arrays. Defaults to 100.
  def memory_size
    @output_ring.max_size
  end

  undef :memory_size= if method_defined? :memory_size=
  def memory_size=(size)
    @input_ring = ProGrammar::Ring.new(size)
    @output_ring = ProGrammar::Ring.new(size)
  end

  # Inject all the sticky locals into the current binding.
  def inject_sticky_locals!
    sticky_locals.each_pair do |name, value|
      inject_local(name, value, current_binding)
    end
  end

  # Add a sticky local to this ProGrammar instance.
  # A sticky local is a local that persists between all bindings in a session.
  # @param [Symbol] name The name of the sticky local.
  # @yield The block that defines the content of the local. The local
  #   will be refreshed at each tick of the repl loop.
  def add_sticky_local(name, &block)
    config.extra_sticky_locals[name] = block
  end

  def sticky_locals
    {
      _in_: input_ring,
      _out_: output_ring,
      pro_grammar_instance: self,
      _ex_: last_exception && last_exception.wrapped_exception,
      _file_: last_file,
      _dir_: last_dir,
      _: proc { last_result },
      __: proc { output_ring[-2] }
    }.merge(config.extra_sticky_locals)
  end

  # Reset the current eval string. If the user has entered part of a multiline
  # expression, this discards that input.
  def reset_eval_string
    @eval_string = ''.dup
  end

  # Pass a line of input to ProGrammar.
  #
  # This is the equivalent of `Binding#eval` but with extra ProGrammar!
  #
  # In particular:
  # 1. ProGrammar commands will be executed immediately if the line matches.
  # 2. Partial lines of input will be queued up until a complete expression has
  #    been accepted.
  # 3. Output is written to `#output` in pretty colours, not returned.
  #
  # Once this method has raised an exception or returned false, this instance
  # is no longer usable. {#exit_value} will return the session's breakout
  # value if applicable.
  #
  # @param [String?] line The line of input; `nil` if the user types `<Ctrl-D>`
  # @option options [Boolean] :generated Whether this line was generated automatically.
  #   Generated lines are not stored in history.
  # @return [Boolean] Is ProGrammar ready to accept more input?
  # @raise [Exception] If the user uses the `raise-up` command, this method
  #   will raise that exception.
  def eval(line, line_number, options = {})
    return false if @stopped

    exit_value = nil
    exception = catch(:raise_up) do
      exit_value = catch(:breakout) do
        handle_line(line, line_number, options)
        # We use 'return !@stopped' here instead of 'return true' so that if
        # handle_line has stopped this pro_grammar instance (e.g. by opening pro_grammar_instance.repl and
        # then popping all the bindings) we still exit immediately.
        return !@stopped
      end
      exception = false
    end

    @stopped = true
    @exit_value = exit_value

    # TODO: make this configurable?
    raise exception if exception

    false
  end

  # Potentially deprecated. Use `ProGrammar::REPL.new(pro_grammar, :target => target).start`
  # (If nested sessions are going to exist, this method is fine, but a goal is
  # to come up with an alternative to nested sessions altogether.)
  def repl(target = nil)
    ProGrammar::REPL.new(self, target: target).start
  end

  def evaluate_ruby(code)
    inject_sticky_locals!
    exec_hook :before_eval, code, self

    result = current_binding.eval(code, ProGrammar.eval_path, ProGrammar.current_line)
    set_last_result(result, code)
  ensure
    update_input_history(code)
    exec_hook :after_eval, result, self
  end

  # Output the result or pass to an exception handler (if result is an exception).
  def show_result(result)
    if last_result_is_exception?
      exception_handler.call(output, result, self)
    elsif should_print?
      print.call(output, result, self)
    end
  rescue RescuableException => e
    # Being uber-paranoid here, given that this exception arose because we couldn't
    # serialize something in the user's program, let's not assume we can serialize
    # the exception either.
    begin
      output.puts "(pro_grammar) output error: #{e.inspect}\n#{e.backtrace.join("\n")}"
    rescue RescuableException
      if last_result_is_exception?
        output.puts "(pro_grammar) output error: failed to show exception"
      else
        output.puts "(pro_grammar) output error: failed to show result"
      end
    end
  ensure
    output.flush if output.respond_to?(:flush)
  end

  # If the given line is a valid command, process it in the context of the
  # current `eval_string` and binding.
  # @param [String] val The line to process.
  # @return [Boolean] `true` if `val` is a command, `false` otherwise
  def process_command(val)
    val = val.lstrip if /^\s\S/ !~ val
    val = val.chomp
    result = commands.process_line(
      val,
      target: current_binding,
      output: output,
      eval_string: @eval_string,
      pro_grammar_instance: self,
      hooks: hooks
    )

    # set a temporary (just so we can inject the value we want into eval_string)
    ProGrammar.current[:pro_grammar_cmd_result] = result

    # note that `result` wraps the result of command processing; if a
    # command was matched and invoked then `result.command?` returns true,
    # otherwise it returns false.
    if result.command?
      unless result.void_command?
        # the command that was invoked was non-void (had a return value) and so we make
        # the value of the current expression equal to the return value
        # of the command.
        @eval_string = "::ProGrammar.current[:pro_grammar_cmd_result].retval\n"
      end
      true
    else
      false
    end
  end

  # Same as process_command, but outputs exceptions to `#output` instead of
  # raising.
  # @param [String] val  The line to process.
  # @return [Boolean] `true` if `val` is a command, `false` otherwise
  def process_command_safely(val)
    process_command(val)
  rescue CommandError,
         ProGrammar::Slop::InvalidOptionError,
         MethodSource::SourceNotFoundError => e
    ProGrammar.last_internal_error = e
    output.puts "Error: #{e.message}"
    true
  end

  # Run the specified command.
  # @param [String] val The command (and its params) to execute.
  # @return [ProGrammar::Command::VOID_VALUE]
  # @example
  #   pro_grammar_instance.run_command("ls -m")
  def run_command(val)
    commands.process_line(
      val,
      eval_string: @eval_string,
      target: current_binding,
      pro_grammar_instance: self,
      output: output
    )
    ProGrammar::Command::VOID_VALUE
  end

  # Execute the specified hook.
  # @param [Symbol] name The hook name to execute
  # @param [*Object] args The arguments to pass to the hook
  # @return [Object, Exception] The return value of the hook or the exception raised
  #
  # If executing a hook raises an exception, we log that and then continue sucessfully.
  # To debug such errors, use the global variable $pro_grammar_hook_error, which is set as a
  # result.
  def exec_hook(name, *args, &block)
    e_before = hooks.errors.size
    hooks.exec_hook(name, *args, &block).tap do
      hooks.errors[e_before..-1].each do |e|
        output.puts "#{name} hook failed: #{e.class}: #{e.message}"
        output.puts e.backtrace.first.to_s
        output.puts "(see pro_grammar_instance.hooks.errors to debug)"
      end
    end
  end

  # Set the last result of an eval.
  # This method should not need to be invoked directly.
  # @param [Object] result The result.
  # @param [String] code The code that was run.
  def set_last_result(result, code = "")
    @last_result_is_exception = false
    @output_ring << result

    self.last_result = result unless code =~ /\A\s*\z/
  end

  # Set the last exception for a session.
  # @param [Exception] exception The last exception.
  def last_exception=(exception)
    @last_result_is_exception = true
    last_exception = ProGrammar::LastException.new(exception)
    @output_ring << last_exception
    @last_exception = last_exception
  end

  # Update ProGrammar's internal state after evalling code.
  # This method should not need to be invoked directly.
  # @param [String] code The code we just eval'd
  def update_input_history(code)
    # Always push to the @input_ring as the @output_ring is always pushed to.
    @input_ring << code
    return unless code

    ProGrammar.line_buffer.push(*code.each_line)
    ProGrammar.current_line += code.lines.count
  end

  # @return [Boolean] True if the last result is an exception that was raised,
  #   as opposed to simply an instance of Exception (like the result of
  #   Exception.new)
  def last_result_is_exception?
    @last_result_is_exception
  end

  # Whether the print proc should be invoked.
  # Currently only invoked if the output is not suppressed.
  # @return [Boolean] Whether the print proc should be invoked.
  def should_print?
    !@suppress_output
  end

  # Returns the appropriate prompt to use.
  # @return [String] The prompt.
  def select_prompt
    object = current_binding.eval('self')
    open_token = @indent.open_delimiters.last || @indent.stack.last

    c = OpenStruct.new(
      object: object,
      nesting_level: binding_stack.size - 1,
      open_token: open_token,
      session_line: ProGrammar.history.session_line_count + 1,
      history_line: ProGrammar.history.history_line_count + 1,
      expr_number: input_ring.count,
      pro_grammar_instance: self,
      binding_stack: binding_stack,
      input_ring: input_ring,
      eval_string: @eval_string,
      cont: !@eval_string.empty?
    )

    ProGrammar.critical_section do
      # If input buffer is empty, then use normal prompt. Otherwise use the wait
      # prompt (indicating multi-line expression).
      if prompt.is_a?(ProGrammar::Prompt)
        prompt_proc = eval_string.empty? ? prompt.wait_proc : prompt.incomplete_proc
        return prompt_proc.call(c.object, c.nesting_level, c.pro_grammar_instance)
      end

      unless @prompt_warn
        @prompt_warn = true
        Kernel.warn(
          "warning: setting prompt with help of " \
          "`ProGrammar.config.prompt = [proc {}, proc {}]` is deprecated. " \
          "Use ProGrammar::Prompt API instead"
        )
      end

      # If input buffer is empty then use normal prompt
      if eval_string.empty?
        generate_prompt(Array(prompt).first, c)
      # Otherwise use the wait prompt (indicating multi-line expression)
      else
        generate_prompt(Array(prompt).last, c)
      end
    end
  end

  # Pushes the current prompt onto a stack that it can be restored from later.
  # Use this if you wish to temporarily change the prompt.
  #
  # @example
  #   push_prompt(ProGrammar::Prompt[:my_prompt])
  #
  # @param [ProGrammar::Prompt] new_prompt
  # @return [ProGrammar::Prompt] new_prompt
  def push_prompt(new_prompt)
    prompt_stack.push new_prompt
  end

  # Pops the current prompt off of the prompt stack. If the prompt you are
  # popping is the last prompt, it will not be popped. Use this to restore the
  # previous prompt.
  #
  # @example
  #    pro_grammar = ProGrammar.new(prompt: ProGrammar::Prompt[:my_prompt1])
  #    pro_grammar.push_prompt(ProGrammar::Prompt[:my_prompt2])
  #    pro_grammar.pop_prompt # => prompt2
  #    pro_grammar.pop_prompt # => prompt1
  #    pro_grammar.pop_prompt # => prompt1
  #
  # @return [ProGrammar::Prompt] the prompt being popped
  def pop_prompt
    prompt_stack.size > 1 ? prompt_stack.pop : prompt
  end

  undef :pager if method_defined? :pager
  # Returns the currently configured pager
  # @example
  #   pro_grammar_instance.pager.page text
  def pager
    ProGrammar::Pager.new(self)
  end

  undef :output if method_defined? :output
  # Returns an output device
  # @example
  #   pro_grammar_instance.output.puts "ohai!"
  def output
    ProGrammar::Output.new(self)
  end

  # Raise an exception out of ProGrammar.
  #
  # See Kernel#raise for documentation of parameters.
  # See rb_make_exception for the inbuilt implementation.
  #
  # This is necessary so that the raise-up command can tell the
  # difference between an exception the user has decided to raise,
  # and a mistake in specifying that exception.
  #
  # (i.e. raise-up RunThymeError.new should not be the same as
  #  raise-up NameError, "unititialized constant RunThymeError")
  #
  def raise_up_common(force, *args)
    exception = if args == []
                  last_exception || RuntimeError.new
                elsif args.length == 1 && args.first.is_a?(String)
                  RuntimeError.new(args.first)
                elsif args.length > 3
                  raise ArgumentError, "wrong number of arguments"
                elsif !args.first.respond_to?(:exception)
                  raise TypeError, "exception class/object expected"
                elsif args.size == 1
                  args.first.exception
                else
                  args.first.exception(args[1])
                end

    raise TypeError, "exception object expected" unless exception.is_a? Exception

    exception.set_backtrace(args.size == 3 ? args[2] : caller(1))

    if force || binding_stack.one?
      binding_stack.clear
      throw :raise_up, exception
    else
      binding_stack.pop
      raise exception
    end
  end

  def raise_up(*args)
    raise_up_common(false, *args)
  end

  def raise_up!(*args)
    raise_up_common(true, *args)
  end

  # Convenience accessor for the `quiet` config key.
  # @return [Boolean]
  def quiet?
    config.quiet
  end

  private

  def handle_line(line, line_number, options)
    if line.nil?
      config.control_d_handler.call(self)
      return
    end

    ensure_correct_encoding!(line)
    ProGrammar.history << line unless options[:generated]

    @suppress_output = false
    inject_sticky_locals!
    begin
      unless process_command_safely(line)
        @eval_string += "#{line.chomp}\n" if !line.empty? || !@eval_string.empty?
      end
    rescue RescuableException => e
      self.last_exception = e
      result = e

      ProGrammar.critical_section do
        show_result(result)
      end
      return
    end

    # This hook is supposed to be executed after each line of ruby code
    # has been read (regardless of whether eval_string is yet a complete expression)
    exec_hook :after_read, eval_string, self

    begin
      complete_expr = ProGrammar::Code.complete_expression?(@eval_string)
    rescue SyntaxError => e
      output.puts e.message.gsub(/^.*syntax error, */, "SyntaxError: ")
      reset_eval_string
    end

    if complete_expr
      if @eval_string =~ /;\Z/ || @eval_string.empty? || @eval_string =~ /\A *#.*\n\z/
        @suppress_output = true
      end

      # A bug in jruby makes java.lang.Exception not rescued by
      # `rescue ProGrammar::RescuableException` clause.
      #
      # * https://github.com/pro_grammar/pro_grammar/issues/854
      # * https://jira.codehaus.org/browse/JRUBY-7100
      #
      # Until that gets fixed upstream, treat java.lang.Exception
      # as an additional exception to be rescued explicitly.
      #
      # This workaround has a side effect: java exceptions specified
      # in `ProGrammar.config.unrescued_exceptions` are ignored.
      jruby_exceptions = []
      jruby_exceptions << Java::JavaLang::Exception if Helpers::Platform.jruby?

      begin
        # Reset eval string, in case we're evaluating Ruby that does something
        # like open a nested REPL on this instance.
        eval_string = @eval_string
        reset_eval_string
        result = evaluate_ruby(eval_string)

        self.display.display_no_error_found
      rescue RescuableException, *jruby_exceptions => e
        # Eliminate following warning:
        # warning: singleton on non-persistent Java type X
        # (http://wiki.jruby.org/Persistence)
        if Helpers::Platform.jruby? && e.class.respond_to?('__persistent__')
          e.class.__persistent__ = true
        end
        self.last_exception = e
        result = e
        ProGrammar::ExceptionHandler.determine_marker_lineno_where_exception(e.class, e, line_number, self)
      end

      ProGrammar.critical_section do
        show_result(result)
      end
    end

    throw(:breakout) if current_binding.nil?
  end

  # Force `eval_string` into the encoding of `val`. [Issue #284]
  def ensure_correct_encoding!(val)
    if @eval_string.empty? &&
       val.respond_to?(:encoding) &&
       val.encoding != @eval_string.encoding
      @eval_string.force_encoding(val.encoding)
    end
  end

  def generate_prompt(prompt_proc, conf)
    if prompt_proc.arity == 1
      prompt_proc.call(conf)
    else
      prompt_proc.call(conf.object, conf.nesting_level, conf.pro_grammar_instance)
    end
  end

  # the array that the prompt stack is stored in
  def prompt_stack
    @prompt_stack ||= []
  end
end
# rubocop:enable Metrics/ClassLength
