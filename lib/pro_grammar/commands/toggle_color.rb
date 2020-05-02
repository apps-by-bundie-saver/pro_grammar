# frozen_string_literal: true

class ProGrammar
  class Command
    class ToggleColor < ProGrammar::ClassCommand
      match 'toggle-color'
      group 'Misc'
      description 'Toggle syntax highlighting.'

      banner <<-'BANNER'
        Usage: toggle-color

        Toggle syntax highlighting.
      BANNER

      def process
        pro_grammar_instance.color = color_toggle
        output.puts "Syntax highlighting #{pro_grammar_instance.color ? 'on' : 'off'}"
      end

      def color_toggle
        !pro_grammar_instance.color
      end

      ProGrammar::Commands.add_command(self)
    end
  end
end
