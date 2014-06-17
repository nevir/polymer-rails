polymer-rails
=============

Make your Rails projects sing with [Polymer](http://polymer-project.org)!

Please note that `polymer-rails` is very much an **alpha** project at this
point. You'll be living on the bleeding edge; pulling gems directly from
GitHub, fending off bugs, and dealing with half-implemented behaviors. That's
the joy of open source!


Getting Started
---------------

### New Rails Projects

You can make use of the [application template](application-template.rb) to
quickly whip up new Polymer-enabled projects:

    rails new -m https://raw.githubusercontent.com/nevir/polymer-rails/master/application-template.rb PROJECT

### Existing Projects

Add `polymer-rails` (and _bleeding edge dependencies_) to your `Gemfile`:

    gem 'polymer-rails', git: 'https://github.com/nevir/polymer-rails'
    gem 'sprockets-htmlimports', git: 'https://github.com/nevir/sprockets-htmlimports'
    gem 'ruby-gumbo', git: 'https://github.com/nevir/ruby-gumbo'

_You may need to run `bundle` more than once; the `ruby-gumbo` installer is a
bit flaky._

Then initialize it via:

    rails generate polymer:init

Before initializing your project, you may want to read on to understand the
flags you can pass, and how they affect the project layout.


What's Different
----------------

`polymer-rails` projects introduce a modified directory structure:

### `app/components`

The bread and butter of your newly Polymerized app: all of your app's web
components should be placed here.

Note that this directory is added to the Sprockets paths, so anything under it
is relative to the `/assets` URL by default.

### `vendor/assets/components`

Third party components (managed by [Bower](http://bower.io/)) reside here.

To add a dependency, modify your `bower.json`, and then run `bower install`.
Cake!

### `app/assets/manifests` (optional)

In this new world of web components, you should find that very little code ends
up under `app/assets/[javascripts|stylesheets]`. To ease that transition,
`polymer-rails` combines your asset manifests into this single directory.

Or, if you would rather not combine your manifests, `polymer-rails` will plunk
the HTML import manifests into `app/assets/components`.

_This is only performed for projects generated via the application template, or
with the `--combine-manifests` option of the `polymer:init` generator._

### `app/assets/(components|manifests)/application.html`

Like you should be used to with the other manifests, this file manages your
app-wide dependencies. Simply `<link href="..." rel="import">` any dependency,
and Sprockets will take care of the rest.

**Note that there is currently no support for `require_tree` style imports!**
You'll have to import each component directly.

### jQuery & Turbolinks Begone!

The DOM is sexy, you don't need no silly abstractions any more, right?

Projects generated via the application template do not include jQuery or
turbolinks. You can also use `--no-default-js` and `--no-turbolinks` to handle
this when running the `polymer:init` generator.


Ok, Now What? (Component Generator)
-----------------------------------

`polymer-rails` also includes a component generator to make your life easy:

    rails generate polymer:component MyComponent

And, like any dutiful generator, it also allows for you to define a quick
skeleton of your component by defining properties:

    rails generate polymer:component BetterComponent foo:string bar:object

Hell, it even supports [slim](http://slim-lang.com) templates if you have
`slim-rails` (>= 2.1.5) installed!


Configuring `polymer-rails`
---------------------------

Take a look at [`config/initializers/polymer.rb`](lib/rails/generators/polymer/init/templates/app/config/initializers/polymer.rb.tt)
for the options you can configure.
