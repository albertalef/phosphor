# frozen_string_literal: true

module Phosphor
  module Objects
    class Line < Base
      attr_accessor :x1_pos, :y1_pos, :x2_pos, :y2_pos, :stroke_char

      def initialize(
        x1_pos,
        y1_pos,
        x2_pos,
        y2_pos,
        stroke_char: '*',
        stroke_color_pair: nil
      )
        @x1_pos = x1_pos
        @y1_pos = y1_pos

        @x2_pos = x2_pos
        @y2_pos = y2_pos

        @stroke_char = stroke_char
        @stroke_color_pair = stroke_color_pair

        super
      end

      def render
        app_instance.canvas.print_at(@x1_pos, @y1_pos, @stroke_char, self)
        app_instance.canvas.print_at(@x2_pos, @y2_pos, @stroke_char, self)

        plot_line(@x1_pos, @y1_pos, @x2_pos, @y2_pos)
      end

      def plot_line(x0, y0, x1, y1)
        dx = (x1 - x0).abs
        dy = (y1 - y0).abs

        sx = x0 < x1 ? 1 : -1
        sy = y0 < y1 ? 1 : -1

        err = dx - dy

        loop do
          app_instance.canvas.print_at(
            x0,
            y0,
            @stroke_char,
            self,
            color_pair: @stroke_color_pair
          )

          break if x0 == x1 && y0 == y1

          e2 = 2 * err

          if e2 > -dy
            err -= dy
            x0 += sx
          end

          if e2 < dx
            err += dx
            y0 += sy
          end
        end
      end
    end
  end
end
