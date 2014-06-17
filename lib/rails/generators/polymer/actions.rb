require 'fileutils'

module Polymer
  module Generators
    module Actions
      def render_template(path)
        full_path = File.expand_path(path)
        context = instance_eval("binding")

        ERB.new(::File.binread(full_path), nil, '-').result(context)
      end

      def remove_line(file, line)
        gsub_file file, "#{line}\n", ''
      end

      def move_file(source, dest)
        message = "#{source} > #{dest}"
        if File.exists?(dest)
          say_status 'skip move', "#{message} (destination exists)", :blue
          return
        end
        if !File.exists?(source)
          say_status 'skip move', "#{message} (source missing)", :blue
          return
        end
        say_status 'move', message, :green

        full_source = File.join(destination_root, source)
        full_dest = File.join(destination_root, dest)
        FileUtils.mkpath(File.dirname(full_dest))
        FileUtils.mv(full_source, full_dest)
      end

      def touch_file(path)
        FileUtils.touch(path)
      end

      def keep_dir(dir)
        full_dir = File.join(destination_root, dir)
        return unless (Dir.entries(full_dir) - %w{. ..}).empty?
        touch_file(File.join(full_dir, '.keep'))
      end
    end
  end
end
