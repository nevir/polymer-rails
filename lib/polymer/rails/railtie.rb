class Polymer::Rails::Railtie < ::Rails::Engine
  config.polymer = ActiveSupport::OrderedOptions.new

  # New components are placed within this directory.
  #
  # Note that components are not placed under assets to avoid precompiling each
  # component into individual sources.
  config.polymer.component_root = File.join('app', 'components')

  initializer :setup_polymer, group: :all do |app|
    config.assets.paths.unshift(config.polymer.component_root)

    # These defaults should map to class_options specified by the generators.
    # TODO(imac): Why aren't options specified at the top level merged in?
    app.config.generators.polymer.reverse_merge!(
      # At the very least, we'll generate <x-*> tags, but you should customize
      # it to something app-specific.
      tag_prefix: 'x',

      # Whether stylesheets should be inlined directly into generated
      # components.
      inline_stylesheet: false,

      # Whether a constructor name should be specified for generated components.
      constructor: false,
    )
  end
end
