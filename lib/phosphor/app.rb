# frozen_string_literal: true

module Phosphor
  class App
    include Phosphor::Objects
    include Phosphor::Rendering

    attr_reader :canvas, :runner, :renderer

    def initialize(
      runner: Runners::RawRunner,
      renderer: Renderers::AnsiRenderer
    )
      @runner = runner
      @renderer = renderer
    end

    def start
      Phosphor::App.instance = self

      @renderer.setup

      @canvas = Canvas.new(@renderer.cols, @renderer.lines)

      @runner.run do
        Phosphor::Events::MainReactor.start

        @runner.next_tick do
          on_start
        end

        @runner.add_periodic_timer(1.0 / 1000) do
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
    end

    def after_render; end

    def stop
      @renderer.close_screen

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
