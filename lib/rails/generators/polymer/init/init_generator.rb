require 'pathname'
require 'polymer/metadata'
require 'rails/generators/polymer/actions'

module Polymer
  module Generators
    class InitGenerator < ::Rails::Generators::Base
      include Polymer::Generators::Actions

      source_root File.expand_path('../templates', __FILE__)

      class_option :combine_manifests, type: :boolean, default: false,
        desc: 'Whether manifests should be moved into a single directory'

      class_option :default_js, type: :boolean, default: true,
        desc: 'Whether default javascript requires should be preserved'

      class_option :turbolinks, type: :boolean, default: true,
        desc: 'Whether turbolinks should be preserved'

      class_option :bower_install, type: :boolean, default: true,
        desc: 'Whether bower install should be run'

      class_option :app_scaffold, type: :boolean, default: false,
        desc: 'Whether a basic app scaffold should be generated'

      def add_app_template
        directory 'app', '.'
      end

      # Manifest Reorganization

      def combine_manifests
        return unless options[:combine_manifests]
        js_path  = combined_manifests_path.join('application.js')
        css_path = combined_manifests_path.join('application.css')

        move_file(assets_path.join('javascripts', 'application.js'),  js_path)
        move_file(assets_path.join('stylesheets', 'application.css'), css_path)

        gsub_file js_path, %r{^\s*//=\s*require_tree\s+\.\s*$} do
          '//= require_tree ../javascripts'
        end
        gsub_file css_path, %r{^(\s*)\*=\s*require_tree\s+\.\s*$} do
          ' *= require_tree ../stylesheets'
        end

        keep_dir assets_path.join('javascripts')
        keep_dir assets_path.join('stylesheets')
      end

      def add_import_manifest
        copy_file(
          'manifests/application.html',
          manifest_path('components', 'application.html')
        )
      end

      # Asset Dependencies

      def require_platform
        js_path = manifest_path('javascripts', 'application.js')
        insert_into_file js_path, before: '//= require_tree .' do
          "//= require platform/platform\n"
        end
      end

      def import_manifest_in_layout
        return unless File.exist? default_layout_path
        insert_into_file default_layout_path, before: /\n\s*<%= csrf_meta_tags/ do
          "\n  <%= html_import_tag        'application' %>"
        end
      end

      def remove_default_js
        return if options[:default_js]
        js_path = manifest_path('javascripts', 'application.js')
        remove_line js_path, '//= require jquery'
        remove_line js_path, '//= require jquery_ujs'
      end

      # Misc

      def disable_turbolinks
        return if options[:turbolinks]
        remove_line(
          manifest_path('javascripts', 'application.js'),
          '//= require turbolinks'
        )

        if File.exist? default_layout_path
          gsub_file default_layout_path, ", 'data-turbolinks-track' => true", ''
        end
      end

      def mobile_meta
        return unless File.exist? default_layout_path
        content = <<-end_content.strip_heredoc.indent(2)
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <meta http-equiv="X-UA-Compatible" content="chrome=1">
        end_content

        insert_into_file default_layout_path, content, after: "</title>\n"
      end

      def add_gitignores
        return unless File.exists? '.gitignore'
        append_to_file '.gitignore', <<-end_content.strip_heredoc

          # Don't bundle bower components with the source
          /vendor/assets/components/
        end_content
      end

      # App Scaffold

      def app_scaffold
        return unless options[:app_scaffold]
        directory 'app_scaffold', '.'

        html_path = manifest_path('components', 'application.html')
        append_to_file html_path, <<-end_content.strip_heredoc
          <link href="core-scaffold/core-scaffold.html" rel="import">
        end_content

        bower_dependencies['core-scaffold'] = 'Polymer/core-scaffold#master'

        route "root 'static#welcome'"
      end

      # Bower

      def configure_bower
        create_file 'bower.json', JSON.pretty_generate({
          name: app_name,
          dependencies: bower_dependencies,
        })

        create_file '.bowerrc', JSON.pretty_generate({
          directory: File.join('vendor', 'assets', 'components'),
        })
      end

      def install_bower_components
        return unless options[:bower_install]
        run 'bower install'
      end

      protected

      def manifest_path(kind, *extras)
        if options[:combine_manifests]
          combined_manifests_path.join(*extras)
        else
          assets_path.join(kind, *extras)
        end
      end

      def combined_manifests_path
        @combined_manifests_path ||=
          Pathname.new(File.join('app', 'assets', 'manifests'))
      end

      def assets_path
        @assets_path ||= Pathname.new(File.join('app', 'assets'))
      end

      def layouts_path
        @layouts_path ||= Pathname.new(File.join('app', 'views', 'layouts'))
      end

      def default_layout_path
        # TODO(imac): Support more than just ERb.
        @default_layout_path ||= layouts_path.join('application.html.erb')
      end

      def app_name
        ::Rails.application.class.parent_name
      end

      def bower_dependencies
        @bower_dependencies ||= {
          # TODO(imac): Support multiple polymer versions!
          "platform" => "Polymer/platform#master",
          "polymer" => "Polymer/polymer#master",
        }
      end
    end
  end
end
