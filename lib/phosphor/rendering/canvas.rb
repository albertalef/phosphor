# frozen_string_literal: true

module Phosphor
  module Rendering
    class Canvas
      attr_reader :width, :height, :objects_at

      def initialize(width, height)
        @width  = width
        @height = height
        @mutex  = Mutex.new

        @pixels = Array.new(@height) { Array.new(@width, " ") }
        @color_pairs = Array.new(@height) { Array.new(@width, nil) }
        @objects_at = Array.new(@height) { Array.new(@width, nil) }

        @prev_pixels = Array.new(@height) { Array.new(@width, nil) }
        @prev_color_pairs = Array.new(@height) { Array.new(@width, nil) }

        @dirty_rows = Array.new(@height, false)
        @prev_dirty_rows = Array.new(@height, true)

        @was_changed = true
      end

      def clear
        @mutex.synchronize do
          @was_changed = true
          @dirty_rows.fill(false)

          @height.times do |y|
            @pixels[y].fill(" ")
            @color_pairs[y].fill(nil)
            @objects_at[y].fill(nil)
          end
        end
      end

      def was_changed?
        @was_changed
      end

      def print_at(x_pos, y_pos, string, owner = nil, color_pair: nil, foreground_color: nil, background_color: nil)
        @mutex.synchronize do
          return if y_pos.negative? || y_pos >= @height

          @was_changed = true
          @dirty_rows[y_pos] = true

          pair_id = if color_pair
                      color_pair.pair_id
                    elsif foreground_color || background_color
                      ColorPair.new(foreground_color, background_color).pair_id
                    end

          pixels_row = @pixels[y_pos]
          cp_row = @color_pairs[y_pos]
          obj_row = @objects_at[y_pos]

          string.each_char.with_index do |ch, i|
            px = x_pos + i
            break if px >= @width
            next if px.negative?

            cp_row[px] = pair_id if pair_id
            pixels_row[px] = ch
            obj_row[px] = owner
          end
        end
      end

      def entity_on(x_pos, y_pos)
        return nil if y_pos.negative? || y_pos >= @height
        return nil if x_pos.negative? || x_pos >= @width

        @objects_at[y_pos][x_pos]
      end

      def render
        @mutex.synchronize do
          return unless @was_changed

          @was_changed = false

          renderer = Phosphor::App.instance.renderer

          @height.times do |y|
            # Only scan rows that are dirty now or were dirty last frame
            next unless @dirty_rows[y] || @prev_dirty_rows[y]

            pixels_row = @pixels[y]
            cp_row = @color_pairs[y]
            prev_pixels_row = @prev_pixels[y]
            prev_cp_row = @prev_color_pairs[y]

            x = 0
            while x < @width
              cp = cp_row[x] || 0
              prev_cp = prev_cp_row[x] || 0

              # Skip unchanged pixels
              if pixels_row[x] == prev_pixels_row[x] && cp == prev_cp
                x += 1
                next
              end

              # Batch consecutive dirty chars with the same color pair
              batch_start = x
              batch = String.new(capacity: 32)
              batch << pixels_row[x]
              x += 1

              while x < @width
                next_cp = cp_row[x] || 0
                break if next_cp != cp
                break if pixels_row[x] == prev_pixels_row[x] && next_cp == (prev_cp_row[x] || 0)

                batch << pixels_row[x]
                x += 1
              end

              renderer.print_at(batch_start, y, batch, cp)
            end
          end

          # Swap buffers instead of copying (O(1) vs O(w*h))
          @prev_pixels, @pixels = @pixels, @prev_pixels
          @prev_color_pairs, @color_pairs = @color_pairs, @prev_color_pairs
          @prev_dirty_rows, @dirty_rows = @dirty_rows, @prev_dirty_rows
        end
      end

      def x_center_pos
        (width / 2).floor
      end

      def y_center_pos
        (height / 2).floor
      end
    end
  end
end
