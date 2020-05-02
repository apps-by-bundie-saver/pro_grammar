# frozen_string_literal: true

class ProGrammar
  # @api private
  # @since v0.13.0
  module ExceptionHandler
    class << self
      # Will only show the first line of the backtrace.
      def handle_exception(output, exception, pro_grammar_instance)
        if exception.is_a?(UserError) && exception.is_a?(SyntaxError)
          output.puts "SyntaxError: #{exception.message.sub(/.*syntax error, */m, '')}"
        else
          output.puts standard_error_text_for(exception)
        end
      end

      def determine_marker_lineno_where_exception(exception_type, exception, line_number, pro_grammar_instance)
        begin
          code = ProGrammar::Code.from_file(pro_grammar_instance.filename).around(pro_grammar_instance.start_trace, pro_grammar_instance.end_trace)
          trace_code = code.instance_variable_get(:@lines).select { |line| line.instance_variable_get(:@tuple)[1] > pro_grammar_instance.start_trace && line.instance_variable_get(:@tuple)[1] < pro_grammar_instance.end_trace }
          pro_grammar_instance.current_note.code = []
          trace_code.each do |code|
            pro_grammar_instance.current_note.code << code
          end
          code = code.select { |line| line.instance_variable_get(:@tuple)[1] > pro_grammar_instance.start_trace && line.instance_variable_get(:@tuple)[1] < pro_grammar_instance.end_trace }
          case exception_type.to_s                               
          when 'NameError'
            undefined_variable_or_method = exception.message.match(/undefined local variable or method \`([@\w\_]+)\' for #<.*>/)[1]
            marker_lineo_code_loc = trace_code.select { |line| line.instance_variable_get(:@tuple)[0].match(/.*=\ +#{undefined_variable_or_method}/) }[0]
            marker_lineo = marker_lineo_code_loc.instance_variable_get(:@tuple)[1]
            pro_grammar_instance.error = { error_type: exception_type, error: exception, line_number: marker_lineo }
            pro_grammar_instance.engine.display_error_tracer(code, marker_lineo)
          else
            pro_grammar_instance.error = { error_type: exception_type, error: exception, line_number: line_number }
            pro_grammar_instance.engine.display_error_tracer(code, line_number)
          end
        rescue Exception => e
          puts e
          puts e.backtrace
        end
      end

      private

      def standard_error_text_for(exception)
        text = exception_text(exception)
        return text unless exception.respond_to?(:cause)

        cause = exception.cause
        while cause
          text += cause_text(cause)
          cause = cause.cause
        end

        text
      end

      def exception_text(exception)
        "#{exception.class}: #{exception.message}\n" \
        "from #{exception.backtrace.first}\n"
      end

      def cause_text(cause)
        "Caused by #{cause.class}: #{cause}\n" \
        "from #{cause.backtrace.first}\n"
      end
    end
  end
end
