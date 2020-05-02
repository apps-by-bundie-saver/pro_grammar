# frozen_string_literal: true

class ProGrammar
  # @return [Array] Code of the method used when implementing ProGrammar's
  #   __binding__, along with line indication to be used with instance_eval (and
  #   friends).
  #
  # @see Object#__binding__
  BINDING_METHOD_IMPL = [<<-METHOD, __FILE__, __LINE__ + 1].freeze
    # Get a binding with 'self' set to self, and no locals.
    #
    # The default definee is determined by the context in which the
    # definition is eval'd.
    #
    # Please don't call this method directly, see {__binding__}.
    #
    # @return [Binding]
    def __pro_grammar_start__
      binding
    end
  METHOD
end

class Object
  # Start a ProGrammar REPL on self.
  #
  # If `self` is a Binding then that will be used to evaluate expressions;
  # otherwise a new binding will be created.
  #
  # @param [Object] object  the object or binding to pro_grammar_start
  #                         (__deprecated__, use `object.pro_grammar_start`)
  # @param [Hash] hash  the options hash
  # @example With a binding
  #    binding.pro_grammar_start
  # @example On any object
  #   "dummy".pro_grammar_start
  # @example With options
  #   def my_method
  #     binding.pro_grammar_start :quiet => true
  #   end
  #   my_method()
  # @see ProGrammar.start
  def pro_grammar_start(object = nil, hash = {})
    end_trace_found = false
    line_num = 1
    filename = caller[0][/[^:]+/]
    file = File.open(caller[0][/[^:]+/]).read
    start_trace_line_number = caller.first.split(":")[1].to_i
    end_trace_line_number = nil

    file.each_line do |line|
      unless end_trace_found
        code_block = line.strip
        if !end_trace_found && code_block =~ /^binding.pro_grammar_end/
          end_trace_line_number = line_num.to_i
          end_trace_found = true
        end
        line_num += 1
      end
    end
    if end_trace_found
      if object.nil? || Hash === object # rubocop:disable Style/CaseEquality
        ProGrammar.start(self, object || {}, filename, start_trace_line_number, end_trace_line_number)
      else
        ProGrammar.start(object, hash, filename, start_trace_line_number, end_trace_line_number)
      end
    else
      raise StandardError.new "Missing 'binding.pro_grammar_end'. Please set a 'pro_grammar_end' when using the ProGrammar GEM."
    end
  end

  def pro_grammar_end
    return 
  end

  # Return a binding object for the receiver.
  #
  # The `self` of the binding is set to the current object, and it contains no
  # local variables.
  #
  # The default definee (http://yugui.jp/articles/846) is set such that:
  #
  # * If `self` is a class or module, then new methods created in the binding
  #   will be defined in that class or module (as in `class Foo; end`).
  # * If `self` is a normal object, then new methods created in the binding will
  #   be defined on its singleton class (as in `class << self; end`).
  # * If `self` doesn't have a  real singleton class (i.e. it is a Fixnum, Float,
  #   Symbol, nil, true, or false), then new methods will be created on the
  #   object's class (as in `self.class.class_eval{ }`)
  #
  # Newly created constants, including classes and modules, will also be added
  # to the default definee.
  #
  # @return [Binding]
  def __binding__
    # If you ever feel like changing this method, be careful about variables
    # that you use. They shouldn't be inserted into the binding that will
    # eventually be returned.

    # When you're cd'd into a class, methods you define should be added to it.
    if is_a?(Module)
      # A special case, for JRuby.
      # Module.new.class_eval("binding") has different behaviour than CRuby,
      # where this is not needed: class_eval("binding") vs class_eval{binding}.
      # Using a block works around the difference of behaviour on JRuby.
      # The scope is clear of local variabless. Don't add any.
      #
      # This fixes the following two spec failures, at https://travis-ci.org/pro_grammar_start/pro_grammar_start/jobs/274470002
      # 1) ./spec/pro_grammar_start_spec.rb:360:in `block in (root)'
      # 2) ./spec/pro_grammar_start_spec.rb:366:in `block in (root)'
      return class_eval { binding } if ProGrammar::Helpers::Platform.jruby? && name.nil?

      # class_eval sets both self and the default definee to this class.
      return class_eval("binding", __FILE__, __LINE__)
    end

    unless self.class.method_defined?(:__binding__)
      # The easiest way to check whether an object has a working singleton class
      # is to try and define a method on it. (just checking for the presence of
      # the singleton class gives false positives for `true` and `false`).
      # __pro_grammar_start__ is just the closest method we have to hand, and using
      # it has the nice property that we can memoize this check.
      begin
        # instance_eval sets the default definee to the object's singleton class
        instance_eval(*ProGrammar::BINDING_METHOD_IMPL)

      # If we can't define methods on the Object's singleton_class. Then we fall
      # back to setting the default definee to be the Object's class. That seems
      # nicer than having a REPL in which you can't define methods.
      rescue TypeError, ProGrammar::FrozenObjectException
        # class_eval sets the default definee to self.class
        self.class.class_eval(*ProGrammar::BINDING_METHOD_IMPL)
      end
    end

    __pro_grammar_start__
  end
end

class BasicObject
  # Return a binding object for the receiver.
  #
  # The `self` of the binding is set to the current object, and it contains no
  # local variables.
  #
  # The default definee (http://yugui.jp/articles/846) is set such that new
  # methods defined will be added to the singleton class of the BasicObject.
  #
  # @return [Binding]
  def __binding__
    # BasicObjects don't have respond_to?, so we just define the method
    # every time. As they also don't have `.freeze`, this call won't
    # fail as it can for normal Objects.
    (class << self; self; end).class_eval(<<-METHOD, __FILE__, __LINE__ + 1)
      # Get a binding with 'self' set to self, and no locals.
      #
      # The default definee is determined by the context in which the
      # definition is eval'd.
      #
      # Please don't call this method directly, see {__binding__}.
      #
      # @return [Binding]
      def __pro_grammar_start__
        ::Kernel.binding
      end
    METHOD
    __pro_grammar_start__
  end
end
