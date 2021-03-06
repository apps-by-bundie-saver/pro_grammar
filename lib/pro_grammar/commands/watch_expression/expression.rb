# frozen_string_literal: true

class ProGrammar
  class Command
    class WatchExpression
      class Expression
        attr_reader :target, :source, :value, :previous_value, :pro_grammar_instance

        def initialize(pro_grammar_instance, target, source)
          @pro_grammar_instance = pro_grammar_instance
          @target = target
          @source = Code.new(source).strip
        end

        def eval!
          @previous_value = value
          @value = ProGrammar::ColorPrinter.pp(target_eval(target, source), ''.dup)
        end

        def to_s
          "#{Code.new(source).highlighted.strip} => #{value}"
        end

        # Has the value of the expression changed?
        #
        # We use the pretty-printed string represenation to detect differences
        # as this avoids problems with dup (causes too many differences) and ==
        # (causes too few)
        def changed?
          (value != previous_value)
        end

        private

        def target_eval(target, source)
          target.eval(source)
        rescue StandardError => e
          e
        end
      end
    end
  end
end
