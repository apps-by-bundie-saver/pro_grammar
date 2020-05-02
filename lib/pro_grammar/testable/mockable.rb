# frozen_string_literal: true

require 'stringio'

class ProGrammar
  module Testable
    module Mockable
      def mock_command(cmd, args = [], opts = {})
        output = StringIO.new
        pro_grammar = ProGrammar.new(output: output)
        ret = cmd.new(opts.merge(pro_grammar_instance: pro_grammar, output: output)).call_safely(*args)
        Struct.new(:output, :return).new(output.string, ret)
      end

      def mock_exception(*mock_backtrace)
        StandardError.new.tap do |e|
          e.define_singleton_method(:backtrace) { mock_backtrace }
        end
      end
    end
  end
end
