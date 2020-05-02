# frozen_string_literal: true

class ProGrammar
  class Command
    class ExitAll < ProGrammar::ClassCommand
      match 'exit-all'
      group 'Navigating ProGrammar'
      description 'End the current ProGrammar session.'

      banner <<-'BANNER'
        Usage:   exit-all [--help]
        Aliases: !!@

        End the current ProGrammar session (popping all bindings and returning to caller).
        Accepts optional return value.
      BANNER

      def process
        # calculate user-given value
        exit_value = target.eval(arg_string)

        # clear the binding stack
        pro_grammar_instance.binding_stack.clear

        # break out of the repl loop
        throw(:breakout, exit_value)
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ExitAll)
    ProGrammar::Commands.alias_command '!!@', 'exit-all'
  end
end
