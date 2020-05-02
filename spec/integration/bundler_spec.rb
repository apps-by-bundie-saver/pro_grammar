# frozen_string_literal: true

require 'rbconfig'

RSpec.describe 'Bundler' do
  let(:ruby) { RbConfig.ruby.shellescape }
  let(:pro_grammar_dir) { File.expand_path(File.join(__FILE__, '../../../lib')).shellescape }

  context "when ProGrammar requires Gemfile, which doesn't specify ProGrammar as a dependency" do
    it "loads auto-completion correctly" do
      code = <<-RUBY
        require "pro_grammar"
        require "bundler/inline"

        # Silence the "The Gemfile specifies no dependencies" warning
        class Bundler::UI::Shell
          def warn(*args, &block); end
        end

        gemfile(true) do
          source "https://rubygems.org"
        end
        exit 42
      RUBY
      `#{ruby} -I#{pro_grammar_dir} -e'#{code}'`
      expect($CHILD_STATUS.exitstatus).to eq(1)
    end
  end
end
