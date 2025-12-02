# frozen_string_literal: true

module Razor
  module Objects
    class Box < Base
      attr_accessor :x_pos, :y_pos,
                    :height, :width,
                    :x_anchor, :y_anchor,
                    :stroke_char, :fill_char

      def initialize(
        height,
        width,
        x_pos = 0,
        y_pos = 0,
        x_anchor: :start,
        y_anchor: :start,
        stroke_char: '*',
        fill_char: nil
      )
        @height = height
        @width = width

        @x_pos = x_pos
        @y_pos = y_pos

        @x_anchor = x_anchor
        @y_anchor = y_anchor

        @stroke_char = stroke_char
        @fill_char = fill_char

        super
      end

      def anchor_from(anchor, dimension)
        case anchor
        when :start
          0
        when :middle
          dimension / 2
        when :end
          dimension
        end
      end

      def x_pos_start = @x_pos - anchor_from(@x_anchor, @width)
      def x_pos_end = x_pos_start + @width

      def y_pos_start = @y_pos - anchor_from(@x_anchor, @height) / 2
      def y_pos_end = y_pos_start + @height / 2

      def render
        x_start = x_pos_start
        x_end = x_pos_end

        y_start = y_pos_start
        y_end = y_pos_end

        canvas = app_instance.canvas

        x_start.upto(x_end) do |x_pos|
          canvas.print_at(x_pos, y_start, @stroke_char, self)
          canvas.print_at(x_pos, y_end, @stroke_char, self)
        end

        y_start.upto(y_end) do |y_pos|
          canvas.print_at(x_start, y_pos, @stroke_char, self)
          canvas.print_at(x_end, y_pos, @stroke_char, self)
        end

        return unless x_end - x_start >= 3 && y_end - y_start >= 3
        return unless @fill_char

        (x_start + 1).upto(x_end - 1) do |x_pos|
          (y_start + 1).upto(y_end - 1) do |y_pos|
            canvas.print_at(x_pos, y_pos, @fill_char, self)
          end
        end
      end
    end
  end
end
