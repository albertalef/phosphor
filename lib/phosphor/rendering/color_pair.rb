module Phosphor
  module Rendering
    class ColorPair
      attr_reader :pair_id, :foreground_color, :background_color

      def initialize(foreground_color, background_color = nil)
        @pair_id = self.class.generate_new_pair_id

        @foreground_color = foreground_color
        @background_color = background_color

        Curses.init_pair(
          @pair_id,
          foreground_color.color_id,
          background_color&.color_id || -1
        )
      end

      class << self
        def new(foreground_color, background_color = nil)
          key = [foreground_color.hex, background_color&.hex].join(":")

          instance = pairs[key]

          unless instance
            instance = allocate
            instance.send(:initialize, foreground_color, background_color)
            pairs[key] = instance
          end

          instance
        end

        def pairs
          @pairs ||= {}
        end

        def generate_new_pair_id
          @last_pair_id ||= 0
          @last_pair_id += 1
        end

        def from_foreground_hex(hex)
          Color.from_hex(hex).foreground_pair
        end

        def from_foreground_rgb(*)
          Color.from_rgb(*).foreground_pair
        end
      end
    end
  end
end
