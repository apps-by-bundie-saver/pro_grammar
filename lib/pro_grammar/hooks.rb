# frozen_string_literal: true

class ProGrammar
  # Implements a hooks system for ProGrammar. A hook is a callable that is associated
  # with an event. A number of events are currently provided by ProGrammar, these
  # include: `:when_started`, `:before_session`, `:after_session`.  A hook must
  # have a name, and is connected with an event by the `ProGrammar::Hooks#add_hook`
  # method.
  #
  # @example Adding a hook for the `:before_session` event.
  #   ProGrammar.config.hooks.add_hook(:before_session, :say_hi) do
  #     puts "hello"
  #   end
  class Hooks
    def self.default
      hooks = new
      hooks.add_hook(:before_session, :default) do |_out, _target, pro_grammar_instance|
        next if pro_grammar_instance.quiet?

        pro_grammar_instance.run_command('whereami --quiet')
      end
      hooks
    end

    def initialize
      @hooks = Hash.new { |h, k| h[k] = [] }
    end

    # Ensure that duplicates have their @hooks object.
    def initialize_copy(_orig)
      hooks_dup = @hooks.dup
      @hooks.each do |k, v|
        hooks_dup[k] = v.dup
      end

      @hooks = hooks_dup
    end

    def errors
      @errors ||= []
    end

    # Destructively merge the contents of two `ProGrammar:Hooks` instances.
    #
    # @param [ProGrammar::Hooks] other The `ProGrammar::Hooks` instance to merge
    # @return [ProGrammar:Hooks] The receiver.
    # @see #merge
    def merge!(other)
      @hooks.merge!(other.dup.hooks) do |_key, array, other_array|
        temp_hash = {}
        output = []

        (array + other_array).reverse_each do |pair|
          temp_hash[pair.first] ||= output.unshift(pair)
        end

        output
      end

      self
    end

    # @example
    #   hooks = ProGrammar::Hooks.new.add_hook(:before_session, :say_hi) { puts "hi!" }
    #   ProGrammar::Hooks.new.merge(hooks)
    # @param [ProGrammar::Hooks] other The `ProGrammar::Hooks` instance to merge
    # @return [ProGrammar::Hooks] a new `ProGrammar::Hooks` instance containing a merge of the
    #   contents of two `ProGrammar:Hooks` instances.
    def merge(other)
      dup.tap do |v|
        v.merge!(other)
      end
    end

    # Add a new hook to be executed for the `event_name` event.
    # @param [Symbol] event_name The name of the event.
    # @param [Symbol] hook_name The name of the hook.
    # @param [#call] callable The callable.
    # @yield The block to use as the callable (if no `callable` provided).
    # @return [ProGrammar:Hooks] The receiver.
    def add_hook(event_name, hook_name, callable = nil, &block)
      event_name = event_name.to_s

      # do not allow duplicates, but allow multiple `nil` hooks
      # (anonymous hooks)
      if hook_exists?(event_name, hook_name) && !hook_name.nil?
        raise ArgumentError, "Hook with name '#{hook_name}' already defined!"
      end

      raise ArgumentError, "Must provide a block or callable." if !block && !callable

      # ensure we only have one anonymous hook
      @hooks[event_name].delete_if { |h, _k| h.nil? } if hook_name.nil?

      if block
        @hooks[event_name] << [hook_name, block]
      elsif callable
        @hooks[event_name] << [hook_name, callable]
      end

      self
    end

    # Execute the list of hooks for the `event_name` event.
    # @param [Symbol] event_name The name of the event.
    # @param [Array] args The arguments to pass to each hook function.
    # @return [Object] The return value of the last executed hook.
    def exec_hook(event_name, *args, &block)
      @hooks[event_name.to_s].map do |_hook_name, callable|
        begin
          callable.call(*args, &block)
        rescue RescuableException => e
          errors << e
          e
        end
      end.last
    end

    # @param [Symbol] event_name The name of the event.
    # @return [Fixnum] The number of hook functions for `event_name`.
    def hook_count(event_name)
      @hooks[event_name.to_s].size
    end

    # @param [Symbol] event_name The name of the event.
    # @param [Symbol] hook_name The name of the hook
    # @return [#call] a specific hook for a given event.
    def get_hook(event_name, hook_name)
      hook = @hooks[event_name.to_s].find do |current_hook_name, _callable|
        current_hook_name == hook_name
      end
      hook.last if hook
    end

    # @param [Symbol] event_name The name of the event.
    # @return [Hash] The hash of hook names / hook functions.
    # @note Modifying the returned hash does not alter the hooks, use
    # `add_hook`/`delete_hook` for that.
    def get_hooks(event_name)
      Hash[@hooks[event_name.to_s]]
    end

    # @param [Symbol] event_name The name of the event.
    # @param [Symbol] hook_name The name of the hook.
    #   to delete.
    # @return [#call] The deleted hook.
    def delete_hook(event_name, hook_name)
      deleted_callable = nil

      @hooks[event_name.to_s].delete_if do |current_hook_name, callable|
        if current_hook_name == hook_name
          deleted_callable = callable
          true
        else
          false
        end
      end
      deleted_callable
    end

    # Clear all hooks functions for a given event.
    #
    # @param [String] event_name The name of the event.
    # @return [void]
    def clear_event_hooks(event_name)
      @hooks[event_name.to_s] = []
    end

    # @param [Symbol] event_name Name of the event.
    # @param [Symbol] hook_name Name of the hook.
    # @return [Boolean] Whether the hook by the name `hook_name`.
    def hook_exists?(event_name, hook_name)
      @hooks[event_name.to_s].map(&:first).include?(hook_name)
    end

    protected

    attr_reader :hooks
  end
end
