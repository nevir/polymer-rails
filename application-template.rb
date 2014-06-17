gem 'polymer-rails', git: 'https://github.com/nevir/polymer-rails'
gem 'sprockets-htmlimports', git: 'https://github.com/nevir/sprockets-htmlimports'
# TODO(imac): Remove When/if https://github.com/galdor/ruby-gumbo/pull/5
gem 'ruby-gumbo', git: 'https://github.com/nevir/ruby-gumbo'

run 'bundle'

generate(:"polymer:init",
  '--combine-manifests',
  '--no-default-js',
  '--no-turbolinks',
  '--app-scaffold',
)
