# frozen_string_literal: true

class ProGrammar
  class Command
    class Version < ProGrammar::ClassCommand
      match 'pro_grammar-version'
      group 'Misc'
      description 'Show ProGrammar version.'

      banner <<-'BANNER'
        Show ProGrammar version.
      BANNER

      def process
        output.puts "ProGrammar version: #{ProGrammar::VERSION} on Ruby #{RUBY_VERSION}."
      end
    end

    ProGrammar::Commands.add_command(ProGrammar::Command::Version)
  end
end
