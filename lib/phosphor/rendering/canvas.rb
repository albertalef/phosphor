# frozen_string_literal: true

module Phosphor
  module Rendering
    class Canvas
      attr_reader :width, :height, :objects_at

      def initialize(width, height)
        @width  = width
        @height = height
        @mutex  = Mutex.new
        clear
      end

      def clear
        @mutex.synchronize do
          @pixels = Array.new(@height) { Array.new(@width, " ") }
          @color_pairs = Array.new(@height) { Array.new(@width, nil) }
          @objects_at = Array.new(@height) { Array.new(@width, nil) }
        end
      end

      def was_changed?
        @was_changed
      end

      def print_at(x_pos, y_pos, string, owner = nil, color_pair: nil, foreground_color: nil, background_color: nil)
        @mutex.synchronize do
          return if y_pos.negative? || y_pos >= @height

          @was_changed = true

          string.chars.each_with_index do |ch, i|
            px = x_pos + i
            break if px >= @width
            next if px.negative?

            if color_pair || foreground_color || background_color
              @color_pairs[y_pos][px] = color_pair&.pair_id
              @color_pairs[y_pos][px] ||=
                ColorPair.new(foreground_color, background_color).pair_id
            end
            @pixels[y_pos][px] = ch
            @objects_at[y_pos][px] = owner
          end
        end
      end

      def entity_on(x_pos, y_pos)
        (objects_at[y_pos] || {})[x_pos]
      end

      def render
        @mutex.synchronize do
          return unless was_changed?

          @was_changed = false

          @pixels.each_with_index do |row, y|
            row.each_with_index do |char, x|
              Curses.attron(Curses.color_pair(@color_pairs[y][x] || 0)) do
                Curses.setpos(y, x)
                Curses.addstr(char)
              end
            end
          end
        end
      end

      def x_center_pos
        (width / 2).floor
      end

      def y_center_pos
        (height / 2).floor
      end
    end
  end
end
