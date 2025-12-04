# frozen_string_literal: true

module Phosphor
  module Events
    class MouseEvent
      attr_reader :kind, :button, :direction, :x_pos, :y_pos

      def initialize(raw_button:, raw_state:, x_pos:, y_pos:)
        @raw_button = raw_button
        @raw_state = raw_state
        @x_pos = x_pos - 1
        @y_pos = y_pos - 1

        @mods = {
          shift: (raw_button & 4) != 0,
          meta: (raw_button & 8) != 0,
          ctrl: (raw_button & 16) != 0
        }

        motion = (raw_button & 32) != 0
        wheel  = (raw_button & 64) != 0

        base = raw_button & 3

        if wheel
          @kind = :scroll
          @button = :wheel
          @direction = case base
                       when 0 then :up
                       when 1 then :down
                       when 2 then :left
                       when 3 then :right
                       end
        elsif motion
          @kind = :move
          @button =
            case base
            when 0 then :left
            when 1 then :middle
            when 2 then :right
            when 3 then nil
            end
        else
          @kind = :button
          @button =
            case base
            when 0 then :left
            when 1 then :middle
            when 2 then :right
            when 3 then :release
            end
        end
      end

      def name
        "mouse_#{@kind}"
      end

      def pressed?
        @raw_state == "M"
      end
    end
  end
end
