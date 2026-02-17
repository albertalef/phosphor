# frozen_string_literal: true

require "chunky_png"

module Phosphor
  module Objects
    class Image < Base
      attr_accessor :x_pos, :y_pos,
                    :scale

      def initialize(
        image_path,
        x_pos = 0,
        y_pos = 0,
        scale: 1
      )
        @x_pos = x_pos
        @y_pos = y_pos
        @scale = scale

        image = ChunkyPNG::Image.from_file(image_path)

        @width = image.width
        @height = image.height

        @pixels = {}

        @width.times do |image_x|
          @height.times do |image_y|
            pixel = image.get_pixel(image_x, image_y)

            next unless pixel

            @pixels[image_x] ||= {}

            @pixels[image_x][image_y] = Rendering::ColorPair.from_foreground_hex(pixel.to_s(16).rjust(8, "0")[0..5])
          end
        end

        super
      end

      def render
        canvas = app_instance.canvas
        block = "\u2588\u2588" * @scale.round
        rounded_scale = scale.round

        @width.times do |image_x|
          rx = (@x_pos + image_x * 2 * scale).round

          @height.times do |image_y|
            cp = @pixels[image_x][image_y]
            ry_base = (@y_pos + image_y * scale).round

            rounded_scale.times do |scaled_y|
              canvas.print_at(rx, ry_base + scaled_y, block, self, color_pair: cp)
            end
          end
        end
      end
    end
  end
end
