# frozen_string_literal: true

module Phosphor
  module Renderers
    class AnsiRenderer
      TIOCGWINSZ = 0x5413

      def self.setup
        @original_stty = `stty -g 2>/dev/null`.chomp
        system("stty raw -echo 2>/dev/null")
        $stdout.write("\e[?1049h\e[?25l\e[2J")
        $stdout.flush
      end

      def self.cols
        terminal_size[1]
      end

      def self.lines
        terminal_size[0]
      end

      def self.get_char
        $stdin.read_nonblock(1)
      rescue IO::WaitReadable, EOFError
        nil
      end

      def self.close_screen
        $stdout.write("\e[?25h\e[?1049l")
        $stdout.flush
        system("stty #{@original_stty} 2>/dev/null")
      end

      def self.refresh; end

      def self.init_color(*); end

      def self.init_pair(*); end

      def self.terminal_size
        buf = "\0" * 8
        $stdout.ioctl(TIOCGWINSZ, buf)
        buf.unpack("S!S!")
      rescue StandardError
        [ENV.fetch("LINES", 24).to_i, ENV.fetch("COLUMNS", 80).to_i]
      end
    end
  end
end
