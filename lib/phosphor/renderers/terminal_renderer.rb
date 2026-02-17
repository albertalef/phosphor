# frozen_string_literal: true

require_relative "terminal_renderer/canvas"

module Phosphor
  module Renderers
    module TerminalRenderer
      TIOCGWINSZ = 0x5413
      TCGETS     = 0x5401
      TCSETS     = 0x5402
      TERMIOS_SIZE = 60

      # c_iflag masks
      IGNBRK = 0x1
      BRKINT = 0x2
      PARMRK = 0x8
      ISTRIP = 0x20
      INLCR  = 0x40
      IGNCR  = 0x80
      ICRNL  = 0x100
      IXON   = 0x400
      IFLAG_RAW_MASK = IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON

      # c_oflag masks
      OPOST = 0x1

      # c_cflag masks
      CSIZE  = 0x30
      PARENB = 0x100
      CS8    = 0x30

      # c_lflag masks
      ISIG   = 0x1
      ICANON = 0x2
      ECHO   = 0x8
      ECHONL = 0x40
      IEXTEN = 0x8000
      LFLAG_RAW_MASK = ECHO | ECHONL | ICANON | ISIG | IEXTEN

      module_function

      def canvas_class
        TerminalRenderer::Canvas
      end

      def setup
        @saved_termios = termios_get
        set_raw_mode
        $stdout.write("\e[?1049h\e[?25l\e[2J")
        $stdout.flush
      end

      def cols
        terminal_size[1]
      end

      def lines
        terminal_size[0]
      end

      def get_char
        $stdin.read_nonblock(1)&.force_encoding(Encoding::UTF_8)
      rescue IO::WaitReadable, EOFError
        nil
      end

      def close_screen
        $stdout.write("\e[0m\e[2J\e[H\e[?25h\e[?1049l")
        $stdout.flush
        termios_set(@saved_termios) if @saved_termios
      end

      def terminal_size
        buf = "\0" * 8
        $stdout.ioctl(TIOCGWINSZ, buf)
        buf.unpack("S!S!")
      rescue StandardError
        [ENV.fetch("LINES", 24).to_i, ENV.fetch("COLUMNS", 80).to_i]
      end

      def termios_get
        buf = ("\0" * TERMIOS_SIZE).b
        $stdin.ioctl(TCGETS, buf)
        buf
      end

      def termios_set(buf)
        $stdin.ioctl(TCSETS, buf)
      end

      def set_raw_mode
        buf = termios_get.dup

        iflag = buf[0, 4].unpack1("I") & ~IFLAG_RAW_MASK
        oflag = buf[4, 4].unpack1("I") & ~OPOST
        cflag = (buf[8, 4].unpack1("I") & ~(CSIZE | PARENB)) | CS8
        lflag = buf[12, 4].unpack1("I") & ~LFLAG_RAW_MASK

        buf[0, 4]  = [iflag].pack("I")
        buf[4, 4]  = [oflag].pack("I")
        buf[8, 4]  = [cflag].pack("I")
        buf[12, 4] = [lflag].pack("I")

        termios_set(buf)
      end
    end
  end
end
