# frozen_string_literal: true

module Razor
  module Objects
    class Text < Base
      attr_accessor :text, :x_pos, :y_pos

      def initialize(text = '', x_pos = 0, y_pos = 0)
        @text = text
        @x_pos = x_pos
        @y_pos = y_pos

        super
      end

      def render
        app_instance.canvas.print_at(@x_pos, @y_pos, @text, self)
      end
    end
  end
end
