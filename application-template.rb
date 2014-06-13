# TODO(imac): Document!
# TODO(imac): Move to a generator that works on existing projects too.
require 'fileutils'
require 'json'
require 'pathname'


# Bower Packages
# ==============

bower_dependencies = {
  # TODO(imac): Support multiple polymer versions!
  "platform" => "Polymer/platform#master",
  "polymer" => "Polymer/polymer#master",
}


# Helpers
# =======

def remove_line(file, line)
  gsub_file file, "#{line}\n", ''
end

def move_file(source, dest)
  say_status 'move', "#{source} > #{dest}", :green

  full_source = File.join(destination_root, source)
  full_dest = File.join(destination_root, dest)
  FileUtils.mkpath(File.dirname(full_dest))
  FileUtils.mv(full_source, full_dest)
end

def keep_dir(dir)
  full_dir = File.join(destination_root, dir)
  return unless (Dir.entries(full_dir) - %w{. ..}).empty?
  FileUtils.touch(File.join(full_dir, '.keep'))
end


# Reorganize Assets
# =================

assets_root = Pathname.new(File.join('app', 'assets'))
manifests_root = assets_root.join('manifests')

move_file(
  assets_root.join('javascripts', 'application.js'),
  manifests_root.join('application.js')
)
move_file(
  assets_root.join('stylesheets', 'application.css'),
  manifests_root.join('application.css')
)

keep_dir assets_root.join('javascripts')
keep_dir assets_root.join('stylesheets')

gsub_file 'app/assets/manifests/application.js', '//= require_tree .' do
  '//= require_tree ../javascripts'
end
gsub_file 'app/assets/manifests/application.css', '*= require_tree .' do
  '//= require_tree ../stylesheets'
end


# Undo Defaults
# =============
# TODO(imac): Is there a way to just toggle settings ahead of time?

remove_line 'app/assets/manifests/application.js', '//= require jquery'
remove_line 'app/assets/manifests/application.js', '//= require jquery_ujs'
remove_line 'app/assets/manifests/application.js', '//= require turbolinks'


# polymer-rails
# =============

gem 'polymer-rails', git: 'https://github.com/nevir/polymer-rails'
gem 'sprockets-htmlimports', git: 'https://github.com/nevir/sprockets-htmlimports'

# config/initializers/polymer.rb
# ------------------------------

initializer 'polymer.rb', <<-end_file
Rails.application.config.generators.polymer = {
  # Specify a short prefix to be used for all of your generated components. This
  # serves as a namespace for them.
  tag_prefix: '#{app_name.underscore.dasherize}',

  # Whether components should be generated with stylesheets inlined into their
  # html source file.
  # inline_stylesheet: true,
}
end_file

# app/assets/manifests/application.html
# --------------------------------------

file 'app/assets/manifests/application.html', <<-end_file
<!--
This is a manifest file that'll be compiled into application.html, which will
include all the files imported below.
-->
<link href="polymer/polymer.html" rel="import">
end_file

# app/assets/manifests/application.js
# -------------------------------------

insert_into_file 'app/assets/manifests/application.js', before: '//= require_tree .' do
  "//= require platform/platform\n"
end

# app/views/layouts/application.html.erb
# --------------------------------------

insert_into_file 'app/views/layouts/application.html.erb', <<-end_content, after: "</title>\n"
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="chrome=1">
end_content

gsub_file 'app/views/layouts/application.html.erb', ", 'data-turbolinks-track' => true", ''
insert_into_file 'app/views/layouts/application.html.erb', before: /\s+<%= csrf_meta_tags/ do
  %Q{\n  <%= import_tag 'application' %>}
end


# Scaffold
# ========

bower_dependencies['core-scaffold'] = 'Polymer/core-scaffold#master'

file 'app/views/static/welcome.html', <<-end_file
<core-scaffold>
  <nav>
    TODO(imac): Navigation!
  </nav>
  TODO(imac): Content!
</core-scaffold>
end_file

append_to_file 'app/assets/manifests/application.html', <<-end_content
<link href="core-scaffold/core-scaffold.html" rel="import">
end_content

gsub_file 'config/routes.rb', "# root 'welcome#index'", "root 'static#welcome'"

file 'app/controllers/static_controller.rb', <<-end_file
class StaticController < ApplicationController
  def welcome
    # Implicit render of views/static/welcome.html.
  end
end
end_file


# Bower
# =====

file 'bower.json', JSON.pretty_generate({
  name: app_name,
  dependencies: bower_dependencies,
})

file '.bowerrc', JSON.pretty_generate({
  directory: 'vendor/assets/components',
})

run 'bower install'
