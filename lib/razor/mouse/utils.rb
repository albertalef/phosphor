# frozen_string_literal: true

module Razor
  module Mouse
    class Utils
      def self.enable_xterm_1003
        $stdout.write("\e[?1003h") # any-event tracking
        $stdout.write("\e[?1006h") # formato SGR, opcional
        $stdout.flush
      end

      def self.disable_xterm_1003
        $stdout.write("\e[?1003l")
        $stdout.write("\e[?1006l")
        $stdout.flush
      end
    end
  end
end
