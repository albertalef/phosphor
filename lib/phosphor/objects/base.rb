# frozen_string_literal: true

module Phosphor
  module Objects
    class Base
      attr_accessor :app_instance

      def initialize(*_)
        @app_instance = Phosphor::App.instance
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
        Phosphor::Events::InputEventReactor.on(event_name) do |event|
          next unless app_instance.canvas.entity_on(event.y_pos, event.x_pos) == self

          block.call(event, self)
        end

        self
      end

      def self.on(event_name, &block)
        Phosphor::Events::InputEventReactor.on(event_name) do |event|
          next unless Phosphor::App.instance.canvas.entity_on(event.y_pos, event.x_pos).class == self

          block.call(event, self)
        end

        self
      end
    end
  end
end
