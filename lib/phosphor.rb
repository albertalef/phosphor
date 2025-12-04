# frozen_string_literal: true

require 'curses'
require 'eventmachine'

require_relative 'phosphor/events/mouse_event'
require_relative 'phosphor/events/input_event_reactor'
require_relative 'phosphor/events/ray_collision_event'

require_relative 'phosphor/mouse/utils'

require_relative 'phosphor/objects/base'
require_relative 'phosphor/objects/text'
require_relative 'phosphor/objects/line'
require_relative 'phosphor/objects/box'
require_relative 'phosphor/objects/ray'
require_relative 'phosphor/objects/circle'

require_relative 'phosphor/canvas'

require_relative 'phosphor/app'

module Phosphor
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
