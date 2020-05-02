# frozen_string_literal: true

class ProGrammar
  class Command
    class Reset < ProGrammar::ClassCommand
      match 'reset'
      group 'Context'
      description 'Reset the REPL to a clean state.'

      banner <<-'BANNER'
        Reset the REPL to a clean state.
      BANNER

      def process
        output.puts 'ProGrammar reset.'
        exec 'pro_grammar'
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Reset)
  end
end
