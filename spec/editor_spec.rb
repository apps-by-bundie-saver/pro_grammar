# frozen_string_literal: true

require 'pathname'

describe ProGrammar::Editor do
  before do
    # OS-specific tempdir name. For GNU/Linux it's "tmp", for Windows it's
    # something "Temp".
    @tf_dir =
      if ProGrammar::Helpers::Platform.mri_19?
        Pathname.new(Dir::Tmpname.tmpdir)
      else
        Pathname.new(Dir.tmpdir)
      end

    @tf_path = File.join(@tf_dir.to_s, 'hello world.rb')

    @editor = ProGrammar::Editor.new(ProGrammar.new)
  end

  describe ".default" do
    context "when $VISUAL is defined" do
      before do
        allow(ProGrammar::Env).to receive(:[])
        expect(ProGrammar::Env).to receive(:[]).with('VISUAL').and_return('emacs')
      end

      it "returns the value of $VISUAL" do
        expect(described_class.default).to eq('emacs')
      end
    end

    context "when $EDITOR is defined" do
      before do
        allow(ProGrammar::Env).to receive(:[])
        expect(ProGrammar::Env).to receive(:[]).with('EDITOR').and_return('vim')
      end

      it "returns the value of $EDITOR" do
        expect(described_class.default).to eq('vim')
      end
    end

    context "when platform is Windows" do
      before do
        allow(ProGrammar::Env).to receive(:[])
        allow(ProGrammar::Env).to receive(:[]).with('VISUAL').and_return(nil)
        allow(ProGrammar::Env).to receive(:[]).with('EDITOR').and_return(nil)

        allow(ProGrammar::Helpers::Platform).to receive(:windows?).and_return(true)
      end

      it "returns 'notepad'" do
        expect(described_class.default).to eq('notepad')
      end
    end

    context "when no editor is detected" do
      before do
        allow(ENV).to receive(:key?).and_return(false)
        allow(Kernel).to receive(:system)
      end

      %w[editor nano vi].each do |text_editor_name|
        it "shells out to find '#{text_editor_name}'" do
          expect(Kernel).to receive(:system)
            .with("which #{text_editor_name} > /dev/null 2>&1")
          described_class.default
        end
      end
    end
  end

  describe "build_editor_invocation_string", skip: !ProGrammar::Helpers::Platform.windows? do
    it 'should shell-escape files' do
      invocation_str = @editor.build_editor_invocation_string(@tf_path, 5, true)
      expect(invocation_str).to match(/#{@tf_dir}.+hello\\ world\.rb/)
    end
  end

  describe "build_editor_invocation_string on windows" do
    before do
      allow(ProGrammar::Helpers::Platform).to receive(:windows?).and_return(true)
    end

    it "should not shell-escape files" do
      invocation_str = @editor.build_editor_invocation_string(@tf_path, 5, true)
      expect(invocation_str).to match(/hello world\.rb/)
    end
  end

  describe 'invoke_editor with a proc' do
    it 'should not shell-escape files' do
      editor = ProGrammar::Editor.new(ProGrammar.new(editor: proc { |file, _line, _blocking|
        @file = file
        nil
      }))

      editor.invoke_editor(@tf_path, 10, true)
      expect(@file).to eq(@tf_path)
    end
  end
end
