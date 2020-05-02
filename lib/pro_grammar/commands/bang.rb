# frozen_string_literal: true

class ProGrammar
  class Command
    class Bang < ProGrammar::ClassCommand
      match(/^\s*!\s*$/)
      group 'Editing'
      description 'Clear the input buffer.'
      command_options use_prefix: false, listing: '!'

      banner <<-'BANNER'
        Clear the input buffer. Useful if the parsing process goes wrong and you get
        stuck in the read loop.
      BANNER

      def process
        output.puts 'Input buffer cleared!'
        eval_string.replace('')
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Bang)
  end
end
