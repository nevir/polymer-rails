class Polymer::Rails::Railtie < ::Rails::Engine
  config.polymer = ActiveSupport::OrderedOptions.new

  # At the very least, we'll generate <x-*> tags, but you should customize it.
  config.polymer.tag_prefix = 'x'

  # New components are placed within this directory.
  config.polymer.component_root = File.join('app', 'assets', 'components')
end
