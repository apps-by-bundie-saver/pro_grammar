# frozen_string_literal: true

class ProGrammar
  class Command
    class Cd < ProGrammar::ClassCommand
      match 'cd'
      group 'Context'
      description 'Move into a new context (object or scope).'

      banner <<-'BANNER'
        Usage: cd [OPTIONS] [--help]

        Move into new context (object or scope). As in UNIX shells use `cd ..` to go
        back, `cd /` to return to ProGrammar top-level and `cd -` to toggle between last two
        scopes. Complex syntax (e.g `cd ../@x/@y`) also supported.

        cd @x
        cd ..
        cd /
        cd -

        https://github.com/pro_grammar/pro_grammar/wiki/State-navigation#wiki-Changing_scope
      BANNER

      def process
        state.old_stack ||= []

        if arg_string.strip == "-"
          unless state.old_stack.empty?
            pro_grammar_instance.binding_stack, state.old_stack =
              state.old_stack, pro_grammar_instance.binding_stack
          end
        else
          stack = ObjectPath.new(arg_string, pro_grammar_instance.binding_stack).resolve

          if stack && stack != pro_grammar_instance.binding_stack
            state.old_stack = pro_grammar_instance.binding_stack
            pro_grammar_instance.binding_stack = stack
          end
        end
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Cd)
  end
end
