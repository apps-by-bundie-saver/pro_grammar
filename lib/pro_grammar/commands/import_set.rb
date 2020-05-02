# frozen_string_literal: true

class ProGrammar
  class Command
    class ImportSet < ProGrammar::ClassCommand
      match 'import-set'
      group 'Commands'
      # TODO: Provide a better description with examples and a general conception
      # of this command.
      description 'Import a ProGrammar command set.'

      banner <<-'BANNER'
        Import a ProGrammar command set.
      BANNER

      # TODO: resolve unused parameter.
      def process(_command_set_name)
        raise CommandError, "Provide a command set name" if command_set.nil?

        set = target.eval(arg_string)
        pro_grammar_instance.commands.import set
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::ImportSet)
  end
end
