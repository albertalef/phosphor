require "curses"

module Phosphor
  module Renderers
    class CursesRenderer
      def self.setup
        Curses.init_screen
        Curses.noecho
        Curses.curs_set(0)
        Curses.cbreak
        # Curses.stdscr.keypad(true)
        Curses.stdscr.nodelay = true

        Curses.start_color
        Curses.use_default_colors
      end

      def self.print_at(x, y, char, color_pair)
        Curses.attron(Curses.color_pair(color_pair || 0)) do
          Curses.setpos(y, x)
          Curses.addstr(char)
        end
      end

      def self.cols
        Curses.cols
      end

      def self.lines
        Curses.lines
      end

      def self.refresh
        Curses.refresh
      end

      def self.close_screen
        Curses.close_screen
      end

      def self.init_color(color_id, red, green, blue)
        Curses.init_color(color_id, red, green, blue)
      end

      def self.get_char
        Curses.get_char
      end

      def self.init_pair(pair_id, foreground_color_id, background_color_id)
        Curses.init_pair(
          pair_id,
          foreground_color_id,
          background_color_id
        )
      end
    end
  end
end
