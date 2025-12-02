# frozen_string_literal: true

module Razor
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
        @pixels = Array.new(@height) { Array.new(@width, ' ') }
        @objects_at = Array.new(@height) { Array.new(@width, nil) }
      end
    end

    def was_changed?
      @was_changed
    end

    def print_at(x_pos, y_pos, string, owner = nil)
      @mutex.synchronize do
        return if y_pos.negative? || y_pos >= @height

        @was_changed = true

        string.chars.each_with_index do |ch, i|
          px = x_pos + i
          break if px >= @width
          next if px.negative?

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
          Curses.setpos(y, 0)
          Curses.addstr(row.join)
        end
      end
    end
  end
end
