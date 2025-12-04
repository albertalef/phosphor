# frozen_string_literal: true

module Phosphor
  module Objects
    class Ray < Base
      attr_accessor :x1_pos, :y1_pos, :x2_pos, :y2_pos, :stroke_char

      def initialize(
        x1_pos,
        y1_pos,
        x2_pos,
        y2_pos,
        stroke_char: '*'
      )
        @x1_pos = x1_pos
        @y1_pos = y1_pos

        @x2_pos = x2_pos
        @y2_pos = y2_pos

        @stroke_char = stroke_char

        super
      end

      def render
        plot_line(@x1_pos, @y1_pos, @x2_pos, @y2_pos)
      end

      def collision_blocks
        @collision_blocks ||= []
      end

      def on_collide(&block)
        collision_blocks << block
      end

      def plot_line(x0, y0, x1, y1)
        sx0 = x0
        sy0 = y0

        dx = (x1 - x0).abs
        dy = (y1 - y0).abs

        sx = x0 < x1 ? 1 : -1
        sy = y0 < y1 ? 1 : -1

        err = dx - dy

        loop do
          ddx = (sx0 - x1).abs
          ddy = (sy0 - y1).abs

          rdx = (sx0 - x0).abs
          rdy = (sy0 - y0).abs

          des_distance = Math.sqrt(ddx**2.0 + ddy**2.0)
          distance = Math.sqrt(rdx**2.0 + rdy**2.0)

          target = app_instance.canvas.entity_on(x0, y0)

          if target && target.class != self.class
            event = Phosphor::Events::RayCollisionEvent.new(
              x_pos: x0,
              y_pos: y0,
              target:,
              distance:,
              des_distance:
            )

            collision_blocks.each { |b| b.call(event, self) }

            break
          end

          app_instance.canvas.print_at(x0, y0, @stroke_char, self)

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
