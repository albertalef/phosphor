# frozen_string_literal: true

require "eventmachine"

module Phosphor
  module Runners
    class EventMachineRunner
      def self.run(&)
        EventMachine.run(&)
      end

      def self.next_tick(&)
        EventMachine.next_tick(&)
      end

      def self.add_periodic_timer(interval, &block)
        EventMachine.add_periodic_timer(interval, &block)
      end

      def self.stop
        EventMachine.stop
      end

      def self.queue_class
        EventMachine::Queue
      end
    end
  end
end
