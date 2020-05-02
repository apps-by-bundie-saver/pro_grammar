# frozen_string_literal: true

class ProGrammar
  class Inspector
    MAP = {
      "default" => {
        value: ProGrammar.config.print,
        description: <<-DESCRIPTION.each_line.map(&:lstrip!)
          The default ProGrammar inspector. It has paging and color support, and uses
          pretty_inspect when printing an object.
        DESCRIPTION
      },

      "simple" => {
        value: proc do |output, value|
          begin
            output.puts value.inspect
          rescue RescuableException
            output.puts "unknown"
          end
        end,
        description: <<-DESCRIPTION.each_line.map(&:lstrip)
          A simple inspector that uses #puts and #inspect when printing an
          object. It has no pager, color, or pretty_inspect support.
        DESCRIPTION
      },

      "clipped" => {
        value: proc do |output, value|
          output.puts ProGrammar.view_clip(value, id: true)
        end,
        description: <<-DESCRIPTION.each_line.map(&:lstrip)
          The clipped inspector has the same features as the 'simple' inspector
          but prints large objects as a smaller string.
        DESCRIPTION
      }
    }.freeze
  end
end
