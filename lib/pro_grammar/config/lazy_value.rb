# frozen_string_literal: true

class ProGrammar
  class Config
    # LazyValue is a Proc (block) wrapper. It is meant to be used as a
    # configuration value. Subsequent `#call` calls always evaluate the given
    # block.
    #
    # @example
    #   num = 19
    #   value = ProGrammar::Config::LazyValue.new { num += 1 }
    #   value.foo # => 20
    #   value.foo # => 21
    #   value.foo # => 22
    #
    # @api private
    # @since v0.13.0
    # @see ProGrammar::Config::MemoizedValue
    class LazyValue
      def initialize(&block)
        @block = block
      end

      def call
        @block.call
      end
    end
  end
end
