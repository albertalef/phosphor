#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/razor'
require 'debug'

class TextEvent < Razor::App
  def on_start
    Razor::Mouse::Utils.enable_xterm_1003

    @fps_text = Text.new('FPS: x')
    @mouse_text_object = Text.new('', 0, 1)

    @rendered_frames = 0

    EM.add_periodic_timer(1) do
      @fps_text.text = "FPS: #{@rendered_frames}"
      @rendered_frames = 0
    end

    @text = Text.new('Teste agoraaaa', 10, 10)
    @box = Box.new(20, 20, 15, 15)
    @box2 = Box.new(20, 30, 30, 40, fill_char: '-')

    on(:mouse_button) do |event|
      if event.pressed?
        @pressed = canvas.entity_on(event.x_pos, event.y_pos)
        mouse_text = 'YES <<<<<'
      else
        @pressed = nil
        mouse_text = 'no'
      end

      @mouse_text_object.text = "Mouse pressed?: #{mouse_text}"
    end

    @previous_x = 0
    @previous_y = 0

    on(:mouse_move) do |event|
      if @pressed
        @pressed.x_pos += event.x_pos - @previous_x
        @pressed.y_pos += event.y_pos - @previous_y
      end

      @previous_x = event.x_pos
      @previous_y = event.y_pos
    end
  end

  def on_update
    @rendered_frames += 1
  end
end

TextEvent.new.start
