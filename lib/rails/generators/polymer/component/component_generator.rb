module Polymer
  module Generators
    class ComponentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      remove_class_option :skip_namespace

      def initialize(*args)
        super

        global_config = ::Rails.application.config.polymer

        @component_root = global_config.component_root
        @tag_name = "#{global_config.tag_prefix}-#{name.underscore.dasherize}"
      end

      # TODO(imac): Generate proper stylesheet based on stylesheet generator.
      def create_component_files
        options = ::Rails::Generators.options[:rails]

        component_template '%file_name%.html', options[:template_engine]
        component_template '%file_name%.css', options[:template_engine]
      end

      # TODO(imac): Remove this in favor of require_tree support.
      def import_globally
        append_to_file 'app/assets/manifests/application.html', <<-end_content
<link href="#{file_name}/#{file_name}.html" rel="import">
        end_content
      end

      protected

      def component_template(source_path, ext)
        full_path = "#{source_path}.#{ext}.tt"
        if source_paths.any? { |p| File.exist?(File.join(p, full_path)) }
          source_path = "#{source_path}.#{ext}"
        end

        dest_path = File.join(
          @component_root, file_name, File.basename(source_path)
        )
        template source_path, dest_path
      end
    end
  end
end
