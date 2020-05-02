# frozen_string_literal: true

class ProGrammar
  class Command
    class BangProGrammar < ProGrammar::ClassCommand
      match '!pro_grammar'
      group 'Navigating ProGrammar'
      description 'Start a ProGrammar session on current self.'

      banner <<-'BANNER'
        Start a ProGrammar session on current self. Also works mid multi-line expression.
      BANNER

      def process
        target.pro_grammar
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::BangProGrammar)
  end
end
