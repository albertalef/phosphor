# frozen_string_literal: true

module Phosphor
  module Events
    class MainReactor
      class << self
        attr_accessor :queue

        def event_listeners
          @event_listeners ||= {}
        end

        def start
          @queue = EM::Queue.new

          InputEventReactor.start

          start_events_consumer
        end

        def on(event_name, &block)
          event_listeners[event_name.to_sym] ||= []
          event_listeners[event_name.to_sym] << block
        end

        def emit(event)
          @queue.push(event)
        end

        private

        def start_events_consumer
          @queue.pop do |event|
            event_listeners[event.name.to_sym]&.each { |b| b.call(event) }
          ensure
            start_events_consumer
          end
        end
      end
    end
  end
end
