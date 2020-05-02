# frozen_string_literal: true

class ProGrammar
  class Command
    class ChangeInspector < ProGrammar::ClassCommand
      match 'change-inspector'
      group 'Input and Output'
      description 'Change the current inspector proc.'
      command_options argument_required: true
      banner <<-BANNER
        Usage: change-inspector NAME

        Change the proc used to print return values. See list-inspectors for a list
        of available procs and a short description of what each one does.
      BANNER

      def process(inspector)
        unless inspector_map.key?(inspector)
          raise ProGrammar::CommandError, "'#{inspector}' isn't a known inspector!"
        end

        pro_grammar_instance.print = inspector_map[inspector][:value]
        output.puts "Switched to the '#{inspector}' inspector!"
      end

      private

      def inspector_map
        ProGrammar::Inspector::MAP
      end
      ProGrammar::Commands.add_command(self)
    end
  end
end
