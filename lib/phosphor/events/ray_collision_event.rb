# frozen_string_literal: true

module Phosphor
  module Events
    class RayCollisionEvent
      attr_reader :x_pos, :y_pos, :target, :distance, :des_distance

      def initialize(
        x_pos:,
        y_pos:,
        target:,
        distance:,
        des_distance:
      )
        @x_pos = x_pos - 1
        @y_pos = y_pos - 1

        @target = target
        @distance = distance
        @des_distance = des_distance
      end

      def name
        'ray_collide'
      end
    end
  end
end
