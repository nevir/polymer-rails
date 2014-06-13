require 'rails/generators/polymer/actions'

module Polymer
  module Generators
    class ComponentGenerator < ::Rails::Generators::NamedBase
      include Polymer::Generators::Actions

      source_root File.expand_path('../templates', __FILE__)
      remove_class_option :skip_namespace

      argument(:attributes,
        type: :array, default: [], banner: 'attr:type attr:type'
      )

      def initialize(*args)
        super

        global_config = ::Rails.application.config.polymer

        generator_options = ::Rails::Generators.options[:rails]
        @js_engine = generator_options[:javascript_engine] || :js
        @css_engine = generator_options[:stylesheet_engine] || :css
        @tpl_engine = generator_options[:template_engine] || :erb

        @component_root = global_config.component_root
        @tag_name = "#{global_config.tag_prefix}-#{name.underscore.dasherize}"
      end

      # TODO(imac): Generate proper stylesheet based on stylesheet generator.
      def create_component_files
        component_template '%file_name%.html', @tpl_engine
        component_template '%file_name%.css', @css_engine
      end

      # TODO(imac): Remove this in favor of require_tree support.
      def import_globally
        append_to_file 'app/assets/manifests/application.html', <<-end_content
<link href="#{file_name}/#{file_name}.html" rel="import">
        end_content
      end

      protected

      def script_source(script_type = @js_engine)
        ext = @js_engine == :js ? '.js' : ".js.#{@js_engine}"

        render_template(find_in_source_paths(
          File.join('partials', "element_script#{ext}")
        ))
      end

      def component_template(source_path, ext)
        full_path = "#{source_path}.#{ext}"
        begin
          find_in_source_paths(full_path)
        rescue Thor::Error
          full_path = source_path
        end

        dest_path = File.join(
          @component_root, file_name, File.basename(full_path)
        )
        template full_path, dest_path
      end
    end
  end
end
