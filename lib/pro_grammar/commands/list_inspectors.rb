# frozen_string_literal: true

class ProGrammar
  class Command
    class ListInspectors < ProGrammar::ClassCommand
      match 'list-inspectors'
      group 'Input and Output'
      description 'List the inspector procs available for use.'
      banner <<-BANNER
        Usage: list-inspectors

        List the inspector procs available to print return values. You can use
        change-inspector to switch between them.
      BANNER

      def process
        output.puts heading("Available inspectors") + "\n"
        inspector_map.each do |name, inspector|
          output.write "Name: #{bold(name)}"
          output.puts selected_inspector?(inspector) ? selected_text : ""
          output.puts inspector[:description]
          output.puts
        end
      end

      private

      def inspector_map
        ProGrammar::Inspector::MAP
      end

      def selected_text
        red " (selected) "
      end

      def selected_inspector?(inspector)
        pro_grammar_instance.print == inspector[:value]
      end
      ProGrammar::Commands.add_command(self)
    end
  end
end
