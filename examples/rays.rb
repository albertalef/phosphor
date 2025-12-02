#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/razor'
require 'debug'

class Rays < Razor::App
  FILLER_CHARS = [
    '@', '#', 'W', '$', 'M', 'G', 'B', '%',
    'E', 'O', 'C', 'S', 'z', 'o', 'r', 'l',
    'i', ':', ',', '.'
  ]

  BRAILE_CHARS = ['⣿', '⣷', '⢾', '⢹', '⢩', '⠇', '⠃', '⠁']

  def char_color(actual, max)
    percentage = actual / max.to_f

    FILLER_CHARS[(FILLER_CHARS.count * percentage).ceil] || '⠁'
  end

  def on_start
    Razor::Mouse::Utils.enable_xterm_1003

    @fps_text = Text.new('FPS: x')

    @rendered_frames = 0

    EM.add_periodic_timer(1) do
      @fps_text.text = "FPS: #{@rendered_frames}"
      @rendered_frames = 0
    end

    Box.new(
      140,
      200,
      100,
      35,
      x_anchor: :middle,
      y_anchor: :middle
    )

    Box.new(
      30,
      30,
      50,
      35,
      x_anchor: :middle,
      y_anchor: :middle
    )

    @lines = []
    @walls = {}

    @main_angle = 0

    rays = 90
    rays.times do |i|
      final_angle = (i * 10) - 45 - 180 + @main_angle
      line = Ray.new(
        90,
        50,
        90 + (Math.sin(final_angle * Math::PI / 180) * 20).round,
        80 + (Math.cos(final_angle * Math::PI / 180) * 10).round
      )

      @lines << line

      box = Box.new(
        100,
        Curses.cols / rays,
        Curses.cols / (rays - 1) * (i - (rays - 1)).abs,
        (Curses.lines / 2) + 31,
        fill_char: 'X',
        x_anchor: :middle,
        y_anchor: :middle
      )

      box.hide

      @walls[line] = box

      line.on_collide do |event|
        box.height = (event.des_distance - event.distance).ceil / 2 + 40 

        box.fill_char = char_color(event.distance, event.des_distance * 0.9)
        box.stroke_char = char_color(event.distance, event.des_distance * 0.9)

        box.unhide
      end
    end

    on(:mouse_button) do |event|
      if event.pressed?
        @left_pressed = event.button == :left
        @right_pressed = event.button == :right
      else
        @left_pressed = false
        @right_pressed = false
      end
    end

    @previous_x = 0
    @previous_y = 0

    on(:mouse_move) do |event|
      @main_angle += event.x_pos - @previous_x if @left_pressed

      if @right_pressed
        @lines.each do |line|
          line.x1_pos += event.x_pos - @previous_x
          line.y1_pos += event.y_pos - @previous_y
        end
      end

      @previous_x = event.x_pos
      @previous_y = event.y_pos
    end
  end

  def on_update
    @rendered_frames += 1

    @lines.each_with_index do |line, i|
      final_angle = (i * 1) - 45 - 180 + @main_angle
      line.x2_pos = line.x1_pos + (Math.sin(final_angle * Math::PI / 180) * 200).round
      line.y2_pos = line.y1_pos + (Math.cos(final_angle * Math::PI / 180) * 100).round
    end
  end

  def after_render
    @walls.values.each { |a| a.hide }
  end
end

Rays.new.start
