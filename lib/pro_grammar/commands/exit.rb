# frozen_string_literal: true

class ProGrammar
  class Command
    class Exit < ProGrammar::ClassCommand
      match 'exit'
      group 'Navigating ProGrammar'
      description 'Pop the previous binding.'
      command_options keep_retval: true

      banner <<-'BANNER'
        Usage:   exit [OPTIONS] [--help]
        Aliases: quit

        Pop the previous binding (does NOT exit program). It can be useful to exit a
        context with a user-provided value. For instance an exit value can be used to
        determine program flow.

        exit "pro_grammar this"
        exit

        https://github.com/pro_grammar/pro_grammar/wiki/State-navigation#wiki-Exit_with_value
      BANNER

      def process
        if pro_grammar_instance.binding_stack.one?
          pro_grammar_instance.run_command "exit-all #{arg_string}"
        else
          # otherwise just pop a binding and return user supplied value
          process_pop_and_return
        end
      end

      def process_pop_and_return
        popped_object = pro_grammar_instance.binding_stack.pop.eval('self')

        # return a user-specified value if given otherwise return the object
        return target.eval(arg_string) unless arg_string.empty?

        popped_object
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Exit)
    ProGrammar::Commands.alias_command 'quit', 'exit'
  end
end
