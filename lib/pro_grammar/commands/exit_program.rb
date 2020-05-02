# frozen_string_literal: true

class ProGrammar
  class Command
    class ExitProgram < ProGrammar::ClassCommand
      match 'exit-program'
      group 'Navigating ProGrammar'
      description 'End the current program.'

      banner <<-'BANNER'
        Usage:   exit-program [--help]
        Aliases: quit-program
                 !!!

        End the current program.
      BANNER

      def process
        Kernel.exit target.eval(arg_string).to_i
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ExitProgram)
    ProGrammar::Commands.alias_command 'quit-program', 'exit-program'
    ProGrammar::Commands.alias_command '!!!', 'exit-program'
  end
end
