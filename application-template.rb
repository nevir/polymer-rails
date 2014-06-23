gem 'polymer-rails', git: 'https://github.com/nevir/polymer-rails'
gem 'sprockets-htmlimports', git: 'https://github.com/nevir/sprockets-htmlimports'

run 'bundle'

generate(:"polymer:init",
  '--combine-manifests',
  '--no-default-js',
  '--no-turbolinks',
  '--app-scaffold',
)
