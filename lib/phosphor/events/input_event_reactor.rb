# frozen_string_literal: true

module Phosphor
  module Events
    class InputEventReactor
      class << self
        def start
          app_instance = Phosphor::App.instance
          app_instance.runner.add_periodic_timer(0.01) do
            loop do
              ch = app_instance.renderer.read_char
              break if ch.nil?

              case ch
              when "q"
                app_instance.stop
                break
              when "\e"
                handle_escape_sequence(app_instance)
              end
            end
          end
        end

        private

        def handle_escape_sequence(app_instance)
          return unless app_instance.renderer.read_char == "["

          csi = read_csi_sequence(app_instance.renderer)
          return unless /<(\d+);(\d+);(\d+)(m|M)/ =~ csi

          event = MouseEvent.new(
            raw_button: Regexp.last_match(1).to_i,
            raw_state: Regexp.last_match(4),
            x_pos: Regexp.last_match(2).to_i,
            y_pos: Regexp.last_match(3).to_i
          )

          MainReactor.queue.push(event)
        end

        def read_csi_sequence(renderer)
          csi = +""
          loop do
            d = renderer.read_char
            return csi unless d

            csi << d
            break if d.ord >= 0x40 && d.ord <= 0x7E
          end
          csi
        end
      end
    end
  end
end
