# frozen_string_literal: true

require 'ostruct'

class ProGrammar
  class PluginManager
    PRY_PLUGIN_PREFIX = /^pro_grammar-/.freeze

    # Placeholder when no associated gem found, displays warning
    class NoPlugin
      def initialize(name)
        @name = name
      end

      def method_missing(*)
        warn "Warning: The plugin '#{@name}' was not found! (no gem found)"
        super
      end

      def respond_to_missing?(*)
        false
      end
    end

    class Plugin
      attr_accessor :name, :gem_name, :enabled, :spec, :active

      def initialize(name, gem_name, spec, enabled)
        @name = name
        @gem_name = gem_name
        @enabled = enabled
        @spec = spec
      end

      # Disable a plugin. (prevents plugin from being loaded, cannot
      # disable an already activated plugin)
      def disable!
        self.enabled = false
      end

      # Enable a plugin. (does not load it immediately but puts on
      # 'white list' to be loaded)
      def enable!
        self.enabled = true
      end

      # Load the Command line options defined by this plugin (if they exist)
      def load_cli_options
        cli_options_file = File.join(spec.full_gem_path, "lib/#{spec.name}/cli.rb")
        return unless File.exist?(cli_options_file)

        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.4.4")
          cli_options_file = File.realpath(cli_options_file)
        end
        require cli_options_file
      end

      # Activate the plugin (require the gem - enables/loads the
      # plugin immediately at point of call, even if plugin is
      # disabled)
      # Does not reload plugin if it's already active.
      def activate!
        # Create the configuration object for the plugin.
        ProGrammar.config.send("#{gem_name.tr('-', '_')}=", OpenStruct.new)

        begin
          require gem_name unless active?
        rescue LoadError => e
          warn "Found plugin #{gem_name}, but could not require '#{gem_name}'"
          warn e
        rescue StandardError => e
          warn "require '#{gem_name}' # Failed, saying: #{e}"
        end

        self.active = true
        self.enabled = true
      end

      alias active? active
      alias enabled? enabled

      def supported?
        pro_grammar_version = Gem::Version.new(VERSION)
        spec.dependencies.each do |dependency|
          if dependency.name == "pro_grammar"
            return dependency.requirement.satisfied_by?(pro_grammar_version)
          end
        end
        true
      end
    end

    def initialize
      @plugins = []
    end

    # Find all installed ProGrammar plugins and store them in an internal array.
    def locate_plugins
      gem_list.each do |gem|
        next if gem.name !~ PRY_PLUGIN_PREFIX

        plugin_name = gem.name.split('-', 2).last
        plugin = Plugin.new(plugin_name, gem.name, gem, false)
        @plugins << plugin.tap(&:enable!) if plugin.supported? && !plugin_located?(plugin)
      end
      @plugins
    end

    # @return [Hash] A hash with all plugin names (minus the 'pro_grammar-') as
    #   keys and Plugin objects as values.
    def plugins
      h = Hash.new { |_, key| NoPlugin.new(key) }
      @plugins.each do |plugin|
        h[plugin.name] = plugin
      end
      h
    end

    # Require all enabled plugins, disabled plugins are skipped.
    def load_plugins
      @plugins.each do |plugin|
        plugin.activate! if plugin.enabled?
      end
    end

    private

    def plugin_located?(plugin)
      @plugins.any? { |existing| existing.gem_name == plugin.gem_name }
    end

    def gem_list
      Gem.refresh
      return Gem::Specification if Gem::Specification.respond_to?(:each)

      Gem.source_index.find_name('')
    end
  end
end
