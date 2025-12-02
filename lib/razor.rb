# frozen_string_literal: true

require 'curses'
require 'eventmachine'

require_relative 'razor/events/mouse_event'
require_relative 'razor/events/input_event_reactor'
require_relative 'razor/events/ray_collision_event'

require_relative 'razor/mouse/utils'

require_relative 'razor/objects/base'
require_relative 'razor/objects/text'
require_relative 'razor/objects/line'
require_relative 'razor/objects/box'
require_relative 'razor/objects/ray'

require_relative 'razor/canvas'

require_relative 'razor/app'

module Razor
  class << self
    def start
      init_screen
    end

    def hide_cursor
      curs_set(0)
    end

    def show_cursor
      curs_set(1)
    end
  end
end
