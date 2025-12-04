# frozen_string_literal: true

module Phosphor
  module Events
    class InputEventReactor
      class << self
        def event_listeners
          @event_listeners ||= {}
        end

        def start
          @mouse_queue = EM::Queue.new
          @keyboard_queue = EM::Queue.new

          EM.add_periodic_timer(0.01) do
            loop do
              ch = Curses.get_char
              break if ch.nil? # nada pra ler, sai do loop

              case ch
              when 'q'
                return stop
              when "\e" # ESC
                case Curses.get_char
                when '['
                  csi = ''
                  loop do
                    d = Curses.get_char
                    csi += d
                    break if d.ord >= 0x40 && d.ord <= 0x7E
                  end
                  if /<(\d+);(\d+);(\d+)(m|M)/ =~ csi
                    button = Regexp.last_match(1).to_i
                    x = Regexp.last_match(2).to_i
                    y = Regexp.last_match(3).to_i
                    state = Regexp.last_match(4)

                    event = Phosphor::Events::MouseEvent.new(
                      raw_button: button,
                      raw_state: state,
                      x_pos: x,
                      y_pos: y
                    )

                    @mouse_queue.push(event)
                  end
                end
              end
            end
          end

          start_mouse_events_consumer
        end

        def on(event_name, &block)
          event_listeners[event_name.to_sym] ||= []
          event_listeners[event_name.to_sym] << block
        end

        def emit(event)
          @mouse_queue.push(event)
        end

        private

        def start_mouse_events_consumer
          @mouse_queue.pop do |event|
            event_listeners[event.name.to_sym]&.each { |b| b.call(event) }
            event_listeners[:mouse]&.each { |b| b.call(event) }
          ensure
            start_mouse_events_consumer
          end
        end
      end
    end
  end
end
