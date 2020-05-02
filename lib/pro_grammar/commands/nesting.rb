# frozen_string_literal: true

class ProGrammar
  class Command
    class Nesting < ProGrammar::ClassCommand
      match 'nesting'
      group 'Navigating ProGrammar'
      description 'Show nesting information.'

      banner <<-'BANNER'
        Show nesting information.
      BANNER

      def process
        output.puts 'Nesting status:'
        output.puts '--'
        pro_grammar_instance.binding_stack.each_with_index do |obj, level|
          if level == 0
            output.puts "#{level}. #{ProGrammar.view_clip(obj.eval('self'))} (ProGrammar top level)"
          else
            output.puts "#{level}. #{ProGrammar.view_clip(obj.eval('self'))}"
          end
        end
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Nesting)
  end
end
