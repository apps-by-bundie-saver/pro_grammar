# frozen_string_literal: true

require 'etc'

class ProGrammar
  class Display
  	def initialize(pro_grammar_instance)
  		@pro_grammar = pro_grammar_instance
  		@input = nil
  	end

		def display_header
			puts
			puts ("=" * 100).green.bold + "\n"
			puts "Apps by Bundie Saver LLC - ProGrammar".light_magenta.bold
			puts ("-" * 100).blue + "\n"	
			puts "🐇 Start Trace:".light_magenta.bold + "(line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start".blue
			puts ("-" * 100).blue + "\n"	
		end

		def display_footer
			puts ("-" * 100).blue + "\n"	
			puts "🐇 End Trace:".light_magenta.bold + "(line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end".blue
			puts ("-" * 100).blue + "\n"	
			puts ("=" * 100).green.bold + "\n"
		end

		def display_body
      file_code = ProGrammar::Code.from_file(@pro_grammar.filename)
      start_trace = nil
      end_trace = nil
      file_code.lines.each_with_index do |line, index|
        if line.strip.match(/^binding.pro_grammar_start$/)
          start_trace = index
        elsif line.strip.match(/^binding.pro_grammar_end$/)
          end_trace = index
          break
        end
      end
      code = file_code.lines.select.with_index do |line, index|
        if index > start_trace && index < end_trace
          line
        end
      end

      line_number = start_trace + 1
      code.each_with_index do |line, index|
      	line_number = line_number + index 
        begin
        	array_found = line.match(/((^\[)|.*\ *=\ *(\[))/)
        	bloc_found = line.match(/((^(\{)|.*\.[\w+|\_]+\ *(\{|do))|(^(\()|[\w+|\_]+\ *(\()))/)
        	
        	if array_found
        		end_found = false
        		error = ''
        		if array_found[1]
        			end_found = true if line.match(/^\[.*(\])/)
        			error = "missing closing `]\' for array expression"
        		elsif array_found[3]
        			end_found = true if line.match(/.*\ *=\ *\[.*(\])/)
        			error = "missing closing `]\' for array expression"
        		end	
        		unless end_found
	        		marker_lineo = @pro_grammar.start_trace + index + 1
	        		@pro_grammar.error = { error_type: 'SyntaxError', error: error, line_number: marker_lineo }

	        		code = ProGrammar::Code.from_file(@pro_grammar.filename).around(@pro_grammar.start_trace, @pro_grammar.end_trace)
			        pretty_code = code.with_line_numbers(true)
			          .with_marker(marker_lineo)
			          .highlighted

			        display_header

			        @pro_grammar.pager.page(
			          "\n" + "From:".blue.bold + "#{@pro_grammar.filename}:\n\n" + pretty_code + "\n"
			        )

			        display_footer

			        puts "#{@pro_grammar.error[:error_type]}: #{@pro_grammar.error[:error]}".red.bold

			        break
			      end
        	end

        	if bloc_found
	        	end_found = false
	        	error = ''
						if bloc_found[3] == '{' || bloc_found[4] == '{'
	        		end_found = true if line.match(/^\{(\})|.*\.[\w+|\_]+\ *\{.*(\})/)
	        		error = "missing closing `}\' for block expression"
	        	elsif bloc_found[6] == '(' || bloc_found[7] == '('
	        		end_found = true if line.match(/^\((\))|[\w+|\_]+\ *\(.*(\))/)
	        		error = "missing closing `)\' for block expression"
	        	elsif bloc_found[4] == 'do'
	        		end_found = true if line.match(/^do.*(end)|.*\.[\w+|\_]+\ *do.*(end)/)
	        		error = "missing closing `end\' statement for block expression"
	        	end
	        	unless end_found
	        		marker_lineo = @pro_grammar.start_trace + index + 1
	        		@pro_grammar.error = { error_type: 'SyntaxError', error: error, line_number: marker_lineo }

	        		code = ProGrammar::Code.from_file(@pro_grammar.filename).around(@pro_grammar.start_trace, @pro_grammar.end_trace)
			        pretty_code = code.with_line_numbers(true)
			          .with_marker(marker_lineo)
			          .highlighted

			        display_header

			        @pro_grammar.pager.page(
			          "\n" + "From:".blue.bold + "#{@pro_grammar.filename}:\n\n" + pretty_code + "\n"
			        )

			        display_footer

			        puts "#{@pro_grammar.error[:error_type]}: #{@pro_grammar.error[:error]}".red.bold

			        break       		
	        	else
	        		@pro_grammar.eval(line, line_number)
	        	end
	        else
          	@pro_grammar.eval(line, line_number)
        	end
        rescue Exception => e
          puts e
          puts e.backtrace
        end
      end
		end

		def display_no_error_found
			@pro_grammar.error = nil

			display_header

			puts "\n" + "From:".blue.bold + "#{@pro_grammar.filename}:\n\n"

			@pro_grammar.current_note.code = []
			line_indexer = 1
      File.open(@pro_grammar.filename, 'r').each do |line|
      	if line_indexer > @pro_grammar.start_trace && line_indexer < @pro_grammar.end_trace
        	@pro_grammar.current_note.code << ProGrammar::Code::LOC.new(line, line_indexer)
        end
        line_indexer += 1
      end

      @pro_grammar.current_note.code.each do |line|
      	tuple = line.instance_variable_get(:@tuple)
      	puts "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n"
      end

			display_footer

			puts "Wow! No Errors Found".green.bold
			
			return
		end

  	protected

  	def prompt
  		gets.chomp.downcase.strip
  	end

  	def prompt_no_downcase
			gets.chomp
  	end

  	def shell_prefix
  		print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
  	end
  end
end
