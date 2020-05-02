# frozen_string_literal: true

require 'tempfile'

class ProGrammar
  module Testable
    module Utility
      #
      # Creates a Tempfile then unlinks it after the block has yielded.
      #
      # @yieldparam [String] file
      #   The path of the temp file
      #
      # @return [void]
      #
      def temp_file(ext = '.rb')
        file = Tempfile.open(['pro_grammar', ext])
        yield file
      ensure
        file.close(true) if file
      end

      def unindent(*args)
        ProGrammar::Helpers::CommandHelpers.unindent(*args)
      end

      def inner_scope
        catch(:inner_scope) do
          yield -> { throw(:inner_scope, self) }
        end
      end
    end
  end
end
