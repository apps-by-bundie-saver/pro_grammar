# frozen_string_literal: true

class ProGrammar
  class Command
    class DisableProGrammar < ProGrammar::ClassCommand
      match 'disable-pro_grammar'
      group 'Navigating ProGrammar'
      description 'Stops all future calls to pro_grammar and exits the current session.'

      banner <<-'BANNER'
        Usage: disable-pro_grammar

        After this command is run any further calls to pro_grammar will immediately return `nil`
        without interrupting the flow of your program. This is particularly useful when
        you've debugged the problem you were having, and now wish the program to run to
        the end.

        As alternatives, consider using `exit!` to force the current Ruby process
        to quit immediately; or using `edit -p` to remove the `binding.pro_grammar`
        from the code.
      BANNER

      def process
        ENV['DISABLE_PRY'] = 'true'
        pro_grammar_instance.run_command "exit"
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::DisableProGrammar)
  end
end
