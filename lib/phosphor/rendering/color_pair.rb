# frozen_string_literal: true

module Phosphor
  module Rendering
    class ColorPair
      attr_reader :foreground_color, :background_color, :ansi_sequence

      def initialize(foreground_color, background_color = nil)
        @foreground_color = foreground_color
        @background_color = background_color

        @ansi_sequence = build_ansi_sequence
      end

      private

      def build_ansi_sequence
        seq = +""
        if @foreground_color
          r = Color.thousand_to_hex(@foreground_color.red_thousand)
          g = Color.thousand_to_hex(@foreground_color.green_thousand)
          b = Color.thousand_to_hex(@foreground_color.blue_thousand)
          seq << "\e[38;2;#{r};#{g};#{b}m"
        end
        if @background_color
          r = Color.thousand_to_hex(@background_color.red_thousand)
          g = Color.thousand_to_hex(@background_color.green_thousand)
          b = Color.thousand_to_hex(@background_color.blue_thousand)
          seq << "\e[48;2;#{r};#{g};#{b}m"
        end
        seq.freeze
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
