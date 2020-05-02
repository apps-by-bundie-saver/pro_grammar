# frozen_string_literal: true

require 'pp'
require 'English'

class ProGrammar
  # PP subclass for streaming inspect output in color.
  class ColorPrinter < ::PP
    ProGrammar::SyntaxHighlighter.overwrite_coderay_comment_token!

    def self.default(_output, value, pro_grammar_instance)
      pro_grammar_instance.pager.open do |pager|
        pager.print pro_grammar_instance.config.output_prefix
        pp(value, pager, pro_grammar_instance.output.width - 1)
      end
    end

    def self.pp(obj, output = $DEFAULT_OUTPUT, max_width = 79)
      queue = ColorPrinter.new(output, max_width, "\n")
      queue.guard_inspect_key { queue.pp(obj) }
      queue.flush
      output << "\n"
    end

    def pp(object)
      return super unless object.is_a?(String)

      # Avoid calling Ruby 2.4+ String#pretty_print that prints multiline
      # Strings prettier
      text(object.inspect)
    rescue StandardError => exception
      raise if exception.is_a?(ProGrammar::Pager::StopPaging)

      text(highlight_object_literal(inspect_object(object)))
    end

    def text(str, max_width = str.length)
      if str.include?("\e[")
        super("#{str}\e[0m", max_width)
      elsif str.start_with?('#<') || %w[= >].include?(str)
        super(highlight_object_literal(str), max_width)
      else
        super(SyntaxHighlighter.highlight(str), max_width)
      end
    end

    private

    def highlight_object_literal(object_literal)
      code = ProGrammar::SyntaxHighlighter.keyword_token_color
      obj_color = code.start_with?("\e") ? code : "\e[0m\e[0;#{code}m"
      "#{obj_color}#{object_literal}\e[0m"
    end

    def inspect_object(object)
      object.inspect
    rescue StandardError
      # Read the class name off of the singleton class to provide a default
      # inspect.
      singleton = class << object; self; end
      ancestors = ProGrammar::Method.safe_send(singleton, :ancestors)
      klass = ancestors.find { |k| k != singleton }
      "#<#{klass}:0x#{object.__id__.to_s(16)}>"
    end
  end
end
