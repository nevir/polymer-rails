# TODO(imac): Document!
# TODO(imac): Move to a generator that works on existing projects too.
require 'json'


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


# Undo Defaults
# =============
# TODO(imac): Is there a way to just toggle settings ahead of time?

remove_line 'app/assets/javascripts/application.js', '//= require jquery'
remove_line 'app/assets/javascripts/application.js', '//= require jquery_ujs'
remove_line 'app/assets/javascripts/application.js', '//= require turbolinks'


# polymer-rails
# =============

gem 'polymer-rails', path: '../polymer-rails'
gem 'sprockets-htmlimports', path: '../sprockets-htmlimports'

# config/application.rb
# ---------------------

application "config.polymer.tag_prefix = #{app_name.inspect}"

# app/assets/components/application.html
# --------------------------------------

file 'app/assets/components/application.html', <<-end_file
<!--
This is a manifest file that'll be compiled into application.html, which will
include all the files imported below.
-->
<link href="polymer/polymer.html" rel="import">
end_file

# app/assets/javascripts/application.js
# -------------------------------------

insert_into_file 'app/assets/javascripts/application.js', before: '//= require_tree .' do
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

append_to_file 'app/assets/components/application.html', <<-end_content
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
