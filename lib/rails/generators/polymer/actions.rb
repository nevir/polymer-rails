module Polymer
  module Generators
    module Actions
      def render_template(path)
        full_path = File.expand_path(path)
        context = instance_eval("binding")

        ERB.new(::File.binread(full_path), nil, '-').result(context)
      end
    end
  end
end
