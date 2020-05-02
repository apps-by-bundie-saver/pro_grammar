# frozen_string_literal: true

class ProGrammar
  class Note
  	attr_accessor :author
  	attr_accessor :description
  	attr_accessor :note_storage_path
  	attr_accessor :file
  	attr_accessor :code
    attr_accessor :link

  	def initialize
  		@author = nil
  		@description = nil
  		@note_storage_path = nil
  		@file = nil
  		@code = []
      @link = nil
  	end
  end
end
