# !/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/phosphor"
require "debug"

class ImageRenderer < Phosphor::App
  def on_start
    Phosphor::Mouse::Utils.enable_xterm_1003

    @fps_text = Text.new("FPS: x")

    @rendered_frames = 0

    EM.add_periodic_timer(1) do
      @fps_text.text = "FPS: #{@rendered_frames}"
      @rendered_frames = 0
    end

    Box.new(10, 10)

    @image = Image.new(
      "extras/phosphor2.png",
      10,
      scale: 0.5
    )

    @image2 = Image.new(
      "extras/phosphorpixel.png",
      10,
      scale: 1
    )

    on(:mouse_button) do |event|
      if event.pressed?
        @pressed = canvas.entity_on(event.x_pos, event.y_pos)
      else
        @pressed = nil
      end
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

ImageRenderer.new.start
