# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class ProGrammar
  class Engine

  	def initialize(pro_grammar_instance)
      @pro_grammar = pro_grammar_instance
      @error = nil
  	end

    def display_error_tracer(code, marker_lineo)
      @error = marker_lineo

      @pro_grammar.display.display_header

      pretty_code = code.with_line_numbers(true).with_marker(marker_lineo).highlighted

      @pro_grammar.pager.page(
        "\n" + "From:".blue.bold + "#{@pro_grammar.filename}:\n\n" + pretty_code + "\n"
      )

      @pro_grammar.display.display_footer

      if @pro_grammar.attempts.size == 0
        edit_prompt
      end
    end

    def edit_prompt
      if @pro_grammar.attempts.size == 0
        puts "#{@pro_grammar.error[:error_type]} #{@pro_grammar.error[:error]} (line #{@pro_grammar.error[:line_number]})".red.bold
        puts
        puts
        puts "Would you like to create a ProGrammar developer note? (y/n)"
        shell_prefix
      
        @input = prompt

        if @input == 'yes' || @input == 'y'
          puts "Beginning note..."
          puts "Set note author (type the name of the developer creating this note; alternatively, if you want to use your logged in terminal user, type: 'whome'):"
          shell_prefix
          @input = prompt
          if @input == 'whome'
            @pro_grammar.author = Etc.getpwuid(Process.euid).name
            @pro_grammar.current_note.author = Etc.getpwuid(Process.euid).name
          elsif @input == ''
            @pro_grammar.author = "<UnknownAuthor>"
            @pro_grammar.current_note.author = "<UnknownAuthor>"
          else
            @pro_grammar.author = @input
            @pro_grammar.current_note.author = @input
          end
          puts "Writing developer note as: #{@pro_grammar.author}".green.bold
          puts "Okay now..."
          
          store_path    
        elsif @input == 'no' || @input == 'n'
          return
        end
      else
        puts "Would you like to append to your developer note (the same file as the first note you created)? (y/n)".red.bold
        shell_prefix
        @input = prompt
        if @input == 'yes' || @input == 'y'
          puts "Appending to note..."
          puts "Writing developer note as: #{@pro_grammar.author}".green.bold
          puts "Okay now..."
          
          store_path
        elsif @input == 'no' || @input == 'n'
          puts "Oh! Would you like to start a new note? (y/n)".red.bold
          shell_prefix
          @input = prompt
          if @input == 'yes' || @input == 'y'
            
            store_path(new_note = true)
          elsif @input == 'no' || @input == 'n'
            return
          end
        end
      end           
    end

    def store_path(new_note=false)
      if @pro_grammar.attempts.size == 0
        path_set = false
        while path_set == false
          puts "Where would you like this note to be stored:".red.bold
          shell_prefix

          @input = prompt_no_downcase
          if File.directory?(@input)
            path_set = true
          end
        end
        if path_set
          if @input == './' || @input == '.'
            @pro_grammar.note_storage_path = Dir.pwd
          else
            @pro_grammar.note_storage_path = Dir.new(@input).path
          end
          puts "Storing ProGrammar developer notes in: #{@pro_grammar.note_storage_path}".green.bold
          @pro_grammar.current_note.note_storage_path = @pro_grammar.note_storage_path
          @pro_grammar.current_note.file = "pro_grammar_#{@pro_grammar.author}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.txt"
          puts "Would you like to give this note a description? (y/n)".red.bold
          print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
          @input = prompt
          if @input == 'yes' || @input == 'y'
            puts "Setting description (start typing your note description, then hit enter):"
            print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
            @pro_grammar.current_note.description = prompt_no_downcase
            puts "Description set successfully.\n".green.bold
            puts "Please wait while we generate your developer notes..."
            @pro_grammar.attempts << ProGrammar::Attempt.new(@pro_grammar.author, @pro_grammar.description, @pro_grammar.current_note.code, @pro_grammar.start_trace, @pro_grammar.end_trace, @pro_grammar.error, @pro_grammar.current_note.link)
            File.open(@pro_grammar.current_note.file, 'w') do |f|
              f << "#{("=") * 100}\n"
              f << "ORIGINAL TRACE\n"
              f << "#{("_") * 100}\n"
              f << "Developer: #{@pro_grammar.author}\n"
              f << "Date: #{DateTime.now}\n"
              f << "Description: #{@pro_grammar.current_note.description}\n"
              f << "#{("-" * 100)}\n"
              f << "🐇 Start Trace: (line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start\n"
              f << "#{("-" * 100)}\n"
              @pro_grammar.current_note.code.each do |line|
                tuple = line.instance_variable_get(:@tuple)
                if !@pro_grammar.error.nil? && tuple[1] == @pro_grammar.error[:line_number]
                  f << "🐰=>#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                else
                  f << "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                end  
              end
              f << "#{("-" * 100)}\n"
              f << "🐇 End Trace: (line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end\n"
              f << "#{("-" * 100)}\n"
              f << "ERROR FOUND (line #{@pro_grammar.error[:line_number]}): \#<#{@pro_grammar.error[:error_type]}> #{@pro_grammar.error[:error]}\n"
              f << "#{("=") * 100}\n"
            end
            puts "Great! Your developer notes were saved successfully. See them here: #{@pro_grammar.current_note.file}".green.bold

            open_editor
          elsif @input == 'no' || @input == 'n'
            puts "No Description set.\n"
            puts "Please wait while we generate your developer notes..."  
            File.open(@pro_grammar.current_note.file, 'w') do |f|
              f << "#{("=") * 100}\n"
              f << "ORIGINAL TRACE\n"
              f << "#{("_") * 100}\n"
              f << "Developer: #{@pro_grammar.author}\n"
              f << "Date: #{DateTime.now}\n"
              f << "Description: #{@pro_grammar.current_note.description}\n"
              f << "#{("-" * 100)}\n"
              f << "🐇 Start Trace: (line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start\n"
              f << "#{("-" * 100)}\n"
              @pro_grammar.current_note.code.each do |line|
                tuple = line.instance_variable_get(:@tuple)
                if !@pro_grammar.error.nil? && tuple[1] == @pro_grammar.error[:line_number]
                  f << "🐰=>#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                else
                  f << "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                end  
              end
              f << "#{("-" * 100)}\n"
              f << "🐇 End Trace: (line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end\n"
              f << "#{("-" * 100)}\n"
              f << "ERROR FOUND (line #{@pro_grammar.error[:line_number]}): \#<#{@pro_grammar.error[:error_type]}> #{@pro_grammar.error[:error]}\n"
              f << "#{("=") * 100}\n"
            end
            puts "Great! Your developer notes were saved successfully. See them here: #{@pro_grammar.current_note.file}".green.bold


            open_editor
          end
        else
          puts "ERROR: Path must be a directory".red
          store_path
        end       
      else
        if new_note == true
         path_set = false
          while path_set == false
            puts "Where would you like this note to be stored:".red.bold
            shell_prefix

            @input = prompt_no_downcase
            if File.directory?(@input)
              path_set = true
            end
          end
          if path_set
            if @input == './' || @input == '.' 
              @pro_grammar.note_storage_path = Dir.pwd
            else
              @pro_grammar.note_storage_path = Dir.new(@input).path
            end
            
            puts "Storing ProGrammar developer notes in: #{@pro_grammar.note_storage_path}".green.bold
            
            new_note = ProGrammar::Note.new
            new_note.author = @pro_grammar.author
            new_note.note_storage_path = @pro_grammar.note_storage_path
            new_note.file = "pro_grammar_#{@pro_grammar.author}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.txt"
            @pro_grammar.notes << new_note
            @pro_grammar.current_note = new_note
            
            code = ProGrammar::Code.from_file(@pro_grammar.filename).around(@pro_grammar.start_trace, @pro_grammar.end_trace)
            trace_code = code.instance_variable_get(:@lines).select { |line| line.instance_variable_get(:@tuple)[1] > @pro_grammar.start_trace && line.instance_variable_get(:@tuple)[1] < @pro_grammar.end_trace }
            trace_code.each do |code|
              tuple = code.instance_variable_get(:@tuple)
              @pro_grammar.current_note.code << tuple
            end

            puts "Would you like to give this note a description? (y/n)".red.bold
            print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
            @input = prompt
            if @input == 'yes' || @input == 'y'
              puts "Setting description (start typing your note description, then hit enter):"
              print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
              @pro_grammar.current_note.description = prompt_no_downcase
              puts "Description set successfully.\n".green.bold
              puts "Please wait while we generate your developer notes..."
              File.open(@pro_grammar.current_note.file, 'w') do |f|
                f << "#{("=") * 100}\n"
                f << "ORIGINAL TRACE\n"
                f << "#{("_") * 100}\n"
                f << "Developer: #{@pro_grammar.author}\n"
                f << "Date: #{DateTime.now}\n"
                f << "Description: #{@pro_grammar.current_note.description}\n"
                f << "#{("-" * 100)}\n"
                f << "🐇 Start Trace: (line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start\n"
                f << "#{("-" * 100)}\n"
                @pro_grammar.current_note.code.each do |line|
                  tuple = line.instance_variable_get(:@tuple)
                  if !@pro_grammar.error.nil? && tuple[1] == @pro_grammar.error[:line_number]
                    f << "🐰=>#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                  else
                    f << "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                  end  
                end
                f << "#{("-" * 100)}\n"
                f << "🐇 End Trace: (line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end\n"
                f << "#{("-" * 100)}\n"
                f << "ERROR FOUND (line #{@pro_grammar.error[:line_number]}): \#<#{@pro_grammar.error[:error_type]}> #{@pro_grammar.error[:error]}\n"
                f << "#{("=") * 100}\n"
              end
              puts "Great! Your developer notes were saved successfully. See them here: #{@pro_grammar.current_note.file}".green.bold

              open_editor
            else
              puts "No Description set.\n"
              puts "Please wait while we generate your developer notes..."  
              File.open(@pro_grammar.current_note.file, 'w') do |f|
                f << "#{("=") * 100}\n"
                f << "ORIGINAL TRACE\n"
                f << "#{("_") * 100}\n"
                f << "Developer: #{@pro_grammar.author}\n"
                f << "Date: #{DateTime.now}\n"
                f << "Description: #{@pro_grammar.current_note.description}\n"
                f << "#{("-" * 100)}\n"
                f << "🐇 Start Trace: (line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start\n"
                f << "#{("-" * 100)}\n"
                @pro_grammar.current_note.code.each do |line|
                  tuple = line.instance_variable_get(:@tuple)
                  if !@pro_grammar.error.nil? && tuple[1] == @pro_grammar.error[:line_number]
                    f << "🐰=>#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                  else
                    f << "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
                  end  
                end
                f << "#{("-" * 100)}\n"
                f << "🐇 End Trace: (line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end\n"
                f << "#{("-" * 100)}\n"
                f << "ERROR FOUND (line #{@pro_grammar.error[:line_number]}): \#<#{@pro_grammar.error[:error_type]}> #{@pro_grammar.error[:error]}\n"
                f << "#{("=") * 100}\n"
              end
              puts "Great! Your developer notes were saved successfully. See them here: #{@pro_grammar.current_note.file}".green.bold


              open_editor
            end             
          end    
        else
          appending_note = ProGrammar::Note.new
          appending_note.author = @pro_grammar.author
          appending_note.note_storage_path = @pro_grammar.note_storage_path
          appending_note.file = "pro_grammar_#{@pro_grammar.author}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.txt"
          @pro_grammar.notes << appending_note
          @pro_grammar.current_note = appending_note
          
          code = ProGrammar::Code.from_file(@pro_grammar.filename).around(@pro_grammar.start_trace, @pro_grammar.end_trace)
          trace_code = code.instance_variable_get(:@lines).select { |line| line.instance_variable_get(:@tuple)[1] > @pro_grammar.start_trace && line.instance_variable_get(:@tuple)[1] < @pro_grammar.end_trace }
          trace_code.each do |code|
            tuple = code.instance_variable_get(:@tuple)
            @pro_grammar.current_note.code << tuple
          end

          if File.directory?(@pro_grammar.note_storage_path)
            puts "Storing ProGrammar developer notes in: #{@pro_grammar.note_storage_path}".green.bold
            puts "Would you like to give this note a description? (y/n)"
            print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
            @input = prompt
            if @input == 'yes' || @input == 'y'
              puts "Setting description (start typing your note description, then hit enter):"
              print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
              @pro_grammar.current_note.description = prompt_no_downcase
              puts "Description set successfully.\n"

              puts "Great! Your developer notes were appended to successfully. See them here: #{@pro_grammar.current_note}"

              open_editor(true)
            elsif @input == 'no' || @input == 'n'
              puts "No Description set.\n"
              @pro_grammar.current_note.file = File.join(@pro_grammar.note_storage_path, "pro_grammar_#{@pro_grammar.author}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.txt")
              puts "Please wait while we generate your developer notes..."  

              open_editor(true)
            end
          end
        end
      end
    end

    def open_editor(append=false)
      puts "\nNow that you have your developer note document saved. You can edit your trace block code and re-run from your set breakpoints (i.e. binding.pro_grammar_start and binding.pro_grammar_end).\n"
      puts "Would you like to open a VIM session to edit your code between your tracers (afterward your note will be appended to #{File.join(@pro_grammar.note_storage_path, @pro_grammar.current_note.file)}? (y/n)".red.bold
      print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
      @input = prompt
      if @input == 'yes' || @input == 'y'
        temp_file = File.join(@pro_grammar.note_storage_path, "pro_grammar_tempfile.txt")
        File.open(temp_file, 'w') do |f|
          @pro_grammar.current_note.code.each do |line|
            tuple = line.instance_variable_get(:@tuple)
            f << "#{tuple[0]}\n"
          end
        end

        system('vim', temp_file)

        puts "Would you like to give this note a description? (y/n)".red.bold
        print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
        @input = prompt
        if @input == 'yes' || @input == 'y'
          puts "Setting description (start typing your note description, then hit enter):"
          print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
          @pro_grammar.current_note.description = prompt_no_downcase
          puts "Description set successfully.\n".green.bold
        else
          puts "No Description set.\n"
        end

        puts "Would you like to add a link to a solution found on the internet? (y/n)".red.bold
        print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
        @input = prompt
        if @input == 'yes' || @input == 'y'
          puts "Adding link (start typing your note description, then hit enter):"
          print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
          @pro_grammar.current_note.link = prompt_no_downcase.to_s
          puts "Link set successfully.\n".green.bold
        else
          puts "No Link set.\n"
        end

        line_indexer = @pro_grammar.start_trace + 1      
        @pro_grammar.current_note.code = []
        File.open(temp_file, 'r').each do |line|
          @pro_grammar.current_note.code << ProGrammar::Code::LOC.new(line, line_indexer)
          line_indexer += 1
        end

        file_lines = ''
        line_num = 1
        IO.readlines(@pro_grammar.filename).each do |line|
          if line_num <= @pro_grammar.start_trace || line_num >= @pro_grammar.end_trace
            file_lines += line
          end
          line_num += 1
        end

        File.open(@pro_grammar.filename, 'w') do |file|
          file.puts file_lines
        end

        file_lines = ''
        line_num = 1
        insert_line_num = 0
        IO.readlines(@pro_grammar.filename).each do |line|
          if line_num != @pro_grammar.start_trace + 1
            file_lines += line
          elsif line_num == @pro_grammar.start_trace + 1
            @pro_grammar.current_note.code.each do |line|
              tuple = line.instance_variable_get(:@tuple)
              file_lines += tuple[0] + "\n"
              insert_line_num += 1
            end
            file_lines += "\t\tbinding.pro_grammar_end\n"
            @pro_grammar.end_trace = @pro_grammar.start_trace + insert_line_num + 1
          end
          line_num += 1
        end

        File.open(@pro_grammar.filename, 'w') do |file|
          file.puts file_lines
        end

        @pro_grammar.attempts << ProGrammar::Attempt.new(@pro_grammar.author, @pro_grammar.current_note.description, @pro_grammar.current_note.code, @pro_grammar.start_trace, @pro_grammar.end_trace, @pro_grammar.error, @pro_grammar.current_note.link)

        @pro_grammar.display.display_body


        File.open(@pro_grammar.current_note.file, 'a') do |f|
          f << ("=" * 100) + "\n"
          unless @pro_grammar.error.nil?
            f << "RESOLUTION ATTEMPT \#: #{@pro_grammar.attempts.size}\n"
          else
            f << "✓ SOLVED AT RESOLUTION ATTEMPT \#: #{@pro_grammar.attempts.size}\n"
          end
          f << ("_" * 100) + "\n"
          f << "Developer: #{@pro_grammar.current_note.author}\n"
          f << "Date: #{DateTime.now}\n"
          f << "Description: #{@pro_grammar.current_note.description}\n"
          f << "Link: #{@pro_grammar.current_note.link}\n"
          f << ("-" * 100) + "\n"
          f << "🐇 Start Trace: (line #{@pro_grammar.start_trace})\t\tbinding.pro_grammar_start\n"
          f << ("-" * 100) + "\n"
          @pro_grammar.current_note.code.each do |line|
            tuple = line.instance_variable_get(:@tuple)
            if !@pro_grammar.error.nil? && tuple[1] == @pro_grammar.error[:line_number]
              f << "🐰=>#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
            else
              f << "#{tuple[1]}:\t\t#{Strings::ANSI.sanitize(tuple[0])}\n" 
            end  
          end
          f << ("-" * 100) + "\n"
          f << "🐇 End Trace: (line #{@pro_grammar.end_trace})\t\tbinding.pro_grammar_end\n"
          f << ("-" * 100) + "\n"
          unless @pro_grammar.error.nil?
            f << "ERROR FOUND (line #{@pro_grammar.error[:line_number]}): \#<#{@pro_grammar.error[:error_type]}> #{@pro_grammar.error[:error]}\n"
          end
          f << ("=" * 100) + "\n"
        end
        
        File.delete(temp_file) if File.exist?(temp_file)


        unless @pro_grammar.error.nil?
          open_editor
        else
          puts "Would you like to publish this note to the ProGrammar Hub? (y/n)".red.bold
          print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
          @input = prompt
          if @input == 'yes' || @input == 'y'
            puts "Looking to connect to the ProGrammar Hub? No problem. Just sign-in with your Bundie Saver username, email, or phone number.".green.bold
            print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
            username = gets.chomp
            puts "Okay, now type in your password:".green.bold
            print "[Apps by Bundie Saver LLC: ProGrammer]> ".light_magenta.bold
            password = STDIN.noecho(&:gets).chomp

            uri = URI.parse("http://bundiesaver.com/ProGrammar/note/save")

            header = {'Content-Type': 'text/json'}
            note = {
                    username: username,
                    password: password,
                    attempts: @pro_grammar.attempts,
                    note_storage_path: @pro_grammar.note_storage_path,
                    filename: @pro_grammar.filename
                  }

            # Create the HTTP objects
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Post.new(uri.request_uri, header)
            request.body = note.to_json

            # Send the request
            response = http.request(request)
          else
            return
          end
        end
      else
        return 
      end
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