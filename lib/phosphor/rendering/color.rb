module Phosphor
  module Rendering
    class Color
      attr_reader :color_id, :red_thousand, :green_thousand, :blue_thousand

      def initialize(red_thousand, green_thousand, blue_thousand)
        @color_id = self.class.generate_new_color_id

        @red_thousand = red_thousand
        @green_thousand = green_thousand
        @blue_thousand = blue_thousand

        Curses.init_color(@color_id, red_thousand, green_thousand, blue_thousand)
      end

      def foreground_pair
        ColorPair.new(self)
      end

      def hex
        [
          red_thousand,
          green_thousand,
          blue_thousand
        ].map do |a|
          self.class.thousand_to_hex(a).to_s(16)
        end.join.upcase
      end

      class << self
        def from_rgb(red, green, blue)
          from_hex(rgb_to_hex(red, green, blue))
        end

        def from_hex(hex)
          red, green, blue = hex.scan(/.{2}/).map { |a| (a.to_i(16) / 255.to_f * 1000).round }

          colors[hex] ||= new(red, green, blue)
        end

        def colors
          @colors ||= {}
        end

        def generate_new_color_id
          @last_color_id ||= 16
          @last_color_id += 1
        end

        def thousand_to_hex(value)
          (value / 1000.to_f * 255).round
        end

        def rgb_to_hex(red, green, blue)
          [red, green, blue].map { |a| (a / 100.to_f * 255).round.to_s(16).rjust(2, '0') }.join.upcase
        end
      end
    end
  end
end
