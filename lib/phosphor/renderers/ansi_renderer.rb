# frozen_string_literal: true

require "io/console"

module Phosphor
  module Renderers
    class AnsiRenderer
      def self.setup
        $stdin.raw!
        $stdout.write("\e[?1049h\e[?25l\e[2J")
        $stdout.flush
      end

      def self.cols
        IO.console.winsize[1]
      end

      def self.lines
        IO.console.winsize[0]
      end

      def self.get_char
        $stdin.read_nonblock(1)
      rescue IO::WaitReadable, EOFError
        nil
      end

      def self.close_screen
        $stdout.write("\e[?25h\e[?1049l")
        $stdout.flush
        $stdin.cooked!
      end

      def self.refresh; end

      def self.init_color(*); end

      def self.init_pair(*); end
    end
  end
end
