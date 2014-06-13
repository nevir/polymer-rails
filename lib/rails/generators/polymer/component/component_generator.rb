require 'polymer/metadata'
require 'rails/generators/polymer/actions'

module Polymer
  module Generators
    class ComponentGenerator < ::Rails::Generators::NamedBase
      include Polymer::Generators::Actions

      source_root File.expand_path('../templates', __FILE__)
      remove_class_option :skip_namespace

      # These options inherit the defaults specified in Polymer::Rails::Railtie.
      class_option :tag_prefix,        type: :string
      class_option :inline_stylesheet, type: :boolean

      argument(:attributes,
        type: :array, default: [], banner: 'prop:type prop:type'
      )

      def initialize(*args)
        super

        validate_attributes!

        rails_options = ::Rails::Generators.options[:rails]
        @js_engine = rails_options[:javascript_engine] || :js
        @css_engine = rails_options[:stylesheet_engine] || :css
        @tpl_engine = rails_options[:template_engine] || :erb

        @component_root = ::Rails.application.config.polymer.component_root
        @tag_name = "#{options[:tag_prefix]}-#{name.underscore.dasherize}"
      end

      def create_component_files
        component_template '%file_name%.html', @tpl_engine
        unless options[:inline_stylesheet]
          component_template '%file_name%.css', @css_engine
        end
      end

      # TODO(imac): Remove this in favor of require_tree support.
      def import_globally
        append_to_file 'app/assets/manifests/application.html', <<-end_content
<link href="#{file_name}/#{file_name}.html" rel="import">
        end_content
      end

      protected

      def validate_attributes!
        bad_attributes = []
        attributes.each do |attribute|
          attribute.name = canonical_property_name(attribute.name)
          attribute.type = canonical_property_type(attribute.type)

          if Polymer::Metadata.reserved_name? attribute.name
            bad_attributes << attribute
            next
          end
        end

        unless bad_attributes.empty?
          attribute_names = bad_attributes.map { |a| "'#{a.name}'" }.to_sentence
          message = if bad_attributes.size == 1
            "The property name #{attribute_names} is reserved!"
          else
            "The property names #{attribute_names} are reserved!"
          end

          say message, :red
          abort
        end
      end

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
        # TODO(imac): Polymer bug, or just not supported?
        # when :date    then 'new Date(0)'
        when :object  then '{}'
        when :array   then '[]'
        else "''"
        end
      end

      def script_source(script_type = @js_engine)
        ext = script_type == :js ? '.js' : ".js.#{script_type}"

        render_template(find_in_source_paths(
          File.join('partials', "element_script#{ext}")
        ))
      end

      def style_source(style_type = @css_engine)
        ext = style_type == :css ? '.css' : ".css.#{style_type}"

        render_template(find_in_source_paths("%file_name%#{ext}"))
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
