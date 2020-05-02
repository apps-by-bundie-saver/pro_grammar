# frozen_string_literal: true

class ProGrammar
  class Command
    class JumpTo < ProGrammar::ClassCommand
      match 'jump-to'
      group 'Navigating ProGrammar'
      description 'Jump to a binding further up the stack.'

      banner <<-'BANNER'
        Jump to a binding further up the stack, popping all bindings below.
      BANNER

      def process(break_level)
        break_level    = break_level.to_i
        nesting_level  = pro_grammar_instance.binding_stack.size - 1
        max_nest_level = nesting_level - 1

        case break_level
        when nesting_level
          output.puts "Already at nesting level #{nesting_level}"
        when 0..max_nest_level
          pro_grammar_instance.binding_stack = pro_grammar_instance.binding_stack[0..break_level]
        else
          output.puts "Invalid nest level. Must be between 0 and " \
            "#{max_nest_level}. Got #{break_level}."
        end
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::JumpTo)
  end
end
