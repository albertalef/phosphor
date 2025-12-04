# frozen_string_literal: true

module Phosphor
  module Objects
    class Circle < Base
      attr_accessor :radius, :x_pos, :y_pos,
                    :x_anchor, :y_anchor,
                    :stroke_char, :fill_char

      def initialize(
        radius,
        dot_count,
        x_pos = 0,
        y_pos = 0,
        x_anchor: :start,
        y_anchor: :start,
        stroke_char: "*",
        fill_char: nil
      )
        @radius = radius
        @dot_count = dot_count

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
        @dot_count.times do |i|
          percent = i / @dot_count.to_f

          angle_in_rads = percent * Math::PI * 2

          new_x_pos = @x_pos + radius * Math.sin(angle_in_rads)
          new_y_pos = @y_pos + radius * Math.cos(angle_in_rads) / 2

          3.times do |i|
            3.times do |j|
              app_instance.canvas.print_at(new_x_pos - 1 + i, new_y_pos + j - 1, @stroke_char, self)
            end
          end
        end
      end
    end
  end
end
