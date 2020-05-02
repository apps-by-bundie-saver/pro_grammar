# frozen_string_literal: true

class ProGrammar
  module Testable
    module Evalable
      def pro_grammar_tester(*args, &block)
        args.unshift(ProGrammar.toplevel_binding) if args.empty? || args[0].is_a?(Hash)
        ProGrammar::Testable::ProGrammarTester.new(*args).tap do |t|
          t.singleton_class.class_eval(&block) if block
        end
      end

      def pro_grammar_eval(*eval_strs)
        b =
          if eval_strs.first.is_a?(String)
            ProGrammar.toplevel_binding
          else
            ProGrammar.binding_for(eval_strs.shift)
          end
        pro_grammar_tester(b).eval(*eval_strs)
      end
    end
  end
end
