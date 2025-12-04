#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/phosphor'
require 'debug'

class MouseTracker < Phosphor::App
  def on_start
    Phosphor::Mouse::Utils.enable_xterm_1003

    Phosphor::Events::InputEventReactor.start

    @fps_text = Phosphor::Objects::Text.new('FPS: x')
    @mouse_text = Phosphor::Objects::Text.new('', 1, 1)
    @line = Phosphor::Objects::Line.new(0, 0, 0, 0)
    @line.hide
    @box = Phosphor::Objects::Box.new(
      8,
      8,
      10,
      10,
      x_anchor: :middle,
      fill_char: '-'
    )

    @rendered_frames = 0

    EM.add_periodic_timer(1) do
      @fps_text.text = "FPS: #{@rendered_frames}"
      @rendered_frames = 0
    end

    Phosphor::Events::InputEventReactor.on(:mouse) do |event|
      @mouse_text.text = "X: #{event.x_pos} Y: #{event.y_pos}"
    end

    @box.on(:mouse_button) do |box, event|
      if event.button == :left

        @last_pressed_x = event.x_pos
        @last_pressed_y = event.y_pos

        @box_on_last_pressed_x = @box.x_pos
        @box_on_last_pressed_y = @box.y_pos

        if event.pressed?
          @box.fill_char = 'X'

          @line.x1_pos = box.x_pos
          @line.y1_pos = box.y_pos
        else
          @line = Phosphor::Objects::Line.new(0, 0, 0, 0)
          @line.hide

          @last_pressed_x = nil
          @box.fill_char = '-'
        end
      end
    end

    Phosphor::Events::InputEventReactor.on(:mouse_move) do |event|
      next unless @last_pressed_x

      if event.button == :left
        @box.fill_char = 'X'

        @box.x_pos = @box_on_last_pressed_x + event.x_pos - @last_pressed_x
        @box.y_pos = @box_on_last_pressed_y + event.y_pos - @last_pressed_y

        if @line
          @line.unhide
          @line.x2_pos = @box.x_pos
          @line.y2_pos = @box.y_pos
        end
      else
        @box.fill_char = '-'
      end
    end
  end

  def on_update
    @rendered_frames += 1
  end
end

MouseTracker.new.start
