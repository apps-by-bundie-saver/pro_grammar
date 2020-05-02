# frozen_string_literal: true

class ProGrammar
  module Testable
    module Variables
      #
      # @example
      #   temporary_constants(:Foo, :Bar) do
      #     Foo = Class.new(RuntimeError)
      #     Bar = Class.new(RuntimeError)
      #   end
      #   Foo # => NameError
      #   Bar # => NameError
      #
      # @param [Array<Symbol>] names
      #   An array of constant names that be defined by a block,
      #   and removed by this method afterwards.
      #
      # @return [void]
      #
      def temporary_constants(*names)
        names.each do |name|
          Object.remove_const name if Object.const_defined?(name)
        end
        yield
      ensure
        names.each do |name|
          Object.remove_const name if Object.const_defined?(name)
        end
      end

      #
      # @param [String] name
      #   The name of a variable.
      #
      # @param [String] value
      #   Its value.
      #
      # @param [Binding] binding
      #   The binding object to insert a variable into.
      #
      # @return [void]
      #
      def insert_variable(name, value, binding)
        ProGrammar.current[:pro_grammar_local] = value
        binding.eval("#{name} = ::ProGrammar.current[:pro_grammar_local]")
      ensure
        ProGrammar.current[:pro_grammar_local] = nil
      end
    end
  end
end
