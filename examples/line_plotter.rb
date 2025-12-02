#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/razor'
require 'debug'

class LinePlotter < Razor::App
  def on_start
    Razor::Mouse::Utils.enable_xterm_1003

    @fps_text = Text.new('FPS: x')
    @mouse_text = Text.new('', 1, 1)
    @lines = []
    @line = Line.new(0, 0, 0, 0)
    @line.hide
    @lines << @line

    @rendered_frames = 0

    EM.add_periodic_timer(1) do
      @fps_text.text = "FPS: #{@rendered_frames}"
      @rendered_frames = 0
    end

    on(:mouse) do |event|
      @mouse_text.text = "X: #{event.x_pos} Y: #{event.y_pos}"
    end

    on(:mouse_button) do |event|
      if event.button == :left

        @last_pressed_x = event.x_pos
        @last_pressed_y = event.y_pos

        if event.pressed?
          @line.x1_pos = event.x_pos
          @line.y1_pos = event.y_pos
        else
          @line = Line.new(0, 0, 0, 0)
          @line.hide

          @lines << @line

          @last_pressed_x = nil
        end
      else
        @lines.each { |a| a.stroke_char = event.pressed? ? '@' : '-' }
      end
    end

    on(:mouse_scroll) do |event|
      @lines.each(&:hide)
    end

    on(:mouse_move) do |event|
      next unless @last_pressed_x

      if (event.button == :left) && @line
        @line.unhide
        @line.x2_pos = event.x_pos
        @line.y2_pos = event.y_pos
      end
    end
  end

  def on_update
    @rendered_frames += 1
  end
end

LinePlotter.new.start
