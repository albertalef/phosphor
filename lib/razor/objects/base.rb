# frozen_string_literal: true

module Razor
  module Objects
    class Base
      attr_accessor :app_instance

      def initialize(*_)
        @app_instance = Razor::App.instance
        @visible = true

        @app_instance.game_objects << self
      end

      def render; end

      def to_render?
        visible?
      end

      def hidden?
        !@visible
      end

      def visible?
        @visible
      end

      def hide
        @visible = false

        self
      end

      def unhide
        @visible = true

        self
      end

      def on(event_name, &block)
        Razor::Events::InputEventReactor.on(event_name) do |event|
          next unless app_instance.canvas.entity_on(event.y_pos, event.x_pos) == self

          block.call(event, self)
        end

        self
      end
    end
  end
end
