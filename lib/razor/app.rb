# frozen_string_literal: true

module Razor
  class App
    include Razor::Objects

    attr_reader :canvas

    def start
      Razor::App.instance = self

      Curses.init_screen
      Curses.noecho
      Curses.curs_set(0)
      Curses.cbreak
      # Curses.stdscr.keypad(true)
      Curses.stdscr.nodelay = true

      @canvas = Razor::Canvas.new(Curses.cols, Curses.lines)

      EM.run do
        Razor::Events::InputEventReactor.start

        EM.next_tick do
          on_start
        end

        EM.add_periodic_timer(1.0 / 1000) do
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
      @canvas.clear

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

      Razor::Mouse::Utils.disable_xterm_1003

      Razor::App.instance = nil
    end

    def game_objects
      @game_objects ||= []
    end

    def on(event_name, &block)
      Razor::Events::InputEventReactor.on(event_name, &block)
    end

    class << self
      attr_accessor :instance
    end
  end
end
