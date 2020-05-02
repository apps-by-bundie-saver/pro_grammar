# frozen_string_literal: true

class ProGrammar
  class Command
    class SwitchTo < ProGrammar::ClassCommand
      match 'switch-to'
      group 'Navigating ProGrammar'
      description 'Start a new subsession on a binding in the current stack.'

      banner <<-'BANNER'
        Start a new subsession on a binding in the current stack (numbered by nesting).
      BANNER

      def process(selection)
        selection = selection.to_i

        if selection < 0 || selection > pro_grammar_instance.binding_stack.size - 1
          raise CommandError,
                "Invalid binding index #{selection} - use `nesting` command " \
                "to view valid indices."
        else
          ProGrammar.start(pro_grammar_instance.binding_stack[selection])
        end
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::SwitchTo)
  end
end
