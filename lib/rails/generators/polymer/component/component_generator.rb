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

        rails_options = ::Rails::Generators.options[:rails]
        @js_engine = rails_options[:javascript_engine] || :js
        @css_engine = rails_options[:stylesheet_engine] || :css
        @tpl_engine = rails_options[:template_engine] || :erb

        attributes.each do |attribute|
          attribute.name = canonical_property_name(attribute.name)
          attribute.type = canonical_property_type(attribute.type)
        end

        global_config = ::Rails.application.config.polymer
        @component_root = global_config.component_root
        @tag_name = "#{global_config.tag_prefix}-#{name.underscore.dasherize}"
      end

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

      def canonical_property_name(name)
        name.underscore.camelize(:lower)
      end

      def canonical_property_type(type)
        case type
        when :number, :integer, :float, :decimal then :number
        when :string, :text then :string
        when :boolean, :binary then :boolean
        when :date, :time, :datetime, :timestamp then :date
        else type
        end
      end

      def default_property_value(property)
        case property.type
        when :number  then '0'
        when :string  then "''"
        when :boolean then 'false'
        when :date    then 'new Date(0)'
        # TODO(imac): Is {value: *} still necessary?
        when :object  then '{value: {}}'
        when :array   then '{value: []}'
        # TODO(imac): Is string the right default?
        else "''"
        end
      end

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
