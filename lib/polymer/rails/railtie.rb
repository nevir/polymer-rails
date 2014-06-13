class Polymer::Rails::Railtie < ::Rails::Engine
  config.polymer = ActiveSupport::OrderedOptions.new

  # At the very least, we'll generate <x-*> tags, but you should customize it.
  config.polymer.tag_prefix = 'x'

  # New components are placed within this directory.
  #
  # Note that components are not placed under assets to avoid precompiling each
  # component into individual sources.
  config.polymer.component_root = File.join('app', 'components')

  initializer :setup_polymer, group: :all do |app|
    config.assets.paths.unshift(config.polymer.component_root)
  end
end
