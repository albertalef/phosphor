# frozen_string_literal: true

module Phosphor
  class App
    include Phosphor::Objects
    include Phosphor::Rendering

    attr_reader :canvas

    def start
      Phosphor::App.instance = self

      Curses.init_screen
      Curses.noecho
      Curses.curs_set(0)
      Curses.cbreak
      # Curses.stdscr.keypad(true)
      Curses.stdscr.nodelay = true

      Curses.start_color
      Curses.use_default_colors

      @canvas = Canvas.new(Curses.cols, Curses.lines)

      EM.run do
        Phosphor::Events::MainReactor.start

        EM.next_tick do
          on_start
        end

        EM.add_periodic_timer(1.0 / 1000) do
          @canvas.clear
          update
          render
          after_render
        end
      end
    end

    def update
      on_update
    end

    def render
      game_objects.each do |go|
        next unless go.to_render?

        go.render
      end

      @canvas.render

      Curses.refresh
    end

    def after_render
    end

    def stop
      Curses.close_screen

      Phosphor::Mouse::Utils.disable_xterm_1003

      Phosphor::App.instance = nil
    end

    def game_objects
      @game_objects ||= []
    end

    def on(event_name, &block)
      Phosphor::Events::MainReactor.on(event_name, &block)
    end

    class << self
      attr_accessor :instance
    end
  end
end
