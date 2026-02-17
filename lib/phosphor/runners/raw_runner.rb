# frozen_string_literal: true

module Phosphor
  module Runners
    class RawRunner
      def self.run(&block)
        @timers = []
        @next_ticks = []
        @stop = false

        block.call
        reactor_loop
      end

      def self.reactor_loop
        until @stop
          ticks = @next_ticks.dup
          @next_ticks.clear
          ticks.each(&:call)

          now = Time.now.to_f
          @timers.each do |t|
            if now >= t[:next_fire]
              t[:block].call
              t[:next_fire] = now + t[:interval]
            end
          end
        end
      end

      def self.next_tick(&block)
        @next_ticks << block
      end

      def self.add_periodic_timer(interval, &block)
        @timers << { interval: interval, block: block, next_fire: Time.now.to_f + interval }
      end

      def self.stop
        @stop = true
      end

      def self.queue_class
        Queue
      end

      class Queue
        def initialize
          @items = []
          @callbacks = []
        end

        def push(item)
          if @callbacks.any?
            cb = @callbacks.shift
            RawRunner.next_tick { cb.call(item) }
          else
            @items << item
          end
        end

        def pop(&block)
          if @items.any?
            item = @items.shift
            RawRunner.next_tick { block.call(item) }
          else
            @callbacks << block
          end
        end
      end
    end
  end
end
