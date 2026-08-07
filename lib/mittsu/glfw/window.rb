require 'ruby_gl'
require 'glfw'

require 'mittsu/utils'

module Mittsu
  module GLFW
    class Window
      attr_accessor :key_press_handler, :key_release_handler, :key_repeat_handler, :char_input_handler, :cursor_pos_handler, :mouse_button_press_handler, :mouse_button_release_handler, :scroll_handler, :framebuffer_size_handler

      def initialize(width, height, title, antialias: 0)
        ::GLFW.init

        ::GLFW::Window.hint ::GLFW::OPENGL_PROFILE, ::GLFW::OPENGL_CORE_PROFILE
        ::GLFW::Window.hint ::GLFW::OPENGL_FORWARD_COMPAT, GL::TRUE
        ::GLFW::Window.hint ::GLFW::CONTEXT_VERSION_MAJOR, 3
        ::GLFW::Window.hint ::GLFW::CONTEXT_VERSION_MINOR, 3
        ::GLFW::Window.hint ::GLFW::CONTEXT_REVISION, 0

        if antialias > 0
          ::GLFW::Window.hint ::GLFW::SAMPLES, antialias
        end

        @width, @height, @title = width, height, title
        @handle = ::GLFW::Window.new(@width, @height, @title)
        @handle.make_context_current
        ::GLFW::Window.swap_interval = 1

        @handle.on_key do |key, scancode, action, mods|
          case action
          when :press
            key_press_handler.call(key) unless key_press_handler.nil?
            key_repeat_handler.call(key) unless key_repeat_handler.nil?
          when :release
            key_release_handler.call(key) unless key_release_handler.nil?
          when :repeat
            key_repeat_handler.call(key) unless key_repeat_handler.nil?
          end
        end

        @handle.on_char do |codepoint|
          char = [codepoint].pack('U')
          char_input_handler.call(char) unless char_input_handler.nil?
        end

        @handle.on_mouse_move do |xpos, ypos|
          cursor_pos_handler.call(Vector2.new(xpos, ypos)) unless cursor_pos_handler.nil?
        end

        @handle.on_click do |button, action, mods|
          mpos = mouse_position
          case action
          when :press
            mouse_button_press_handler.call(button, mpos) unless mouse_button_press_handler.nil?
          when :release
            mouse_button_release_handler.call(button, mpos) unless mouse_button_release_handler.nil?
          end
        end

        @handle.on_scroll do |xoffset, yoffset|
          scroll_handler.call(Vector2.new(xoffset, yoffset)) unless scroll_handler.nil?
        end

        @handle.on_framebuffer_resize do |new_width, new_height|
          framebuffer_size_handler.call(new_width, new_height) unless framebuffer_size_handler.nil?
        end

        @joystick_buttons = poll_all_joysticks_buttons
      end

      def run
        until @handle.should_close?
          yield

          @handle.swap_buffers
          ::GLFW.poll_events
          poll_joystick_events
        end
        @handle.destroy
        ::GLFW.terminate
      end

      def framebuffer_size
        @handle.framebuffer_size
      end

      def on_key_pressed &block
        @key_press_handler = block
      end

      def on_key_released &block
        @key_release_handler = block
      end

      def on_key_typed &block
        @key_repeat_handler = block
      end

      def key_down?(key)
        @handle.key(key) == :press
      end

      def on_character_input &block
        @char_input_handler = block
      end

      def on_mouse_move &block
        @cursor_pos_handler = block
      end

      def on_mouse_button_pressed &block
        @mouse_button_press_handler = block
      end

      def on_mouse_button_released &block
        @mouse_button_release_handler = block
      end

      def mouse_position
        xpos, ypos = @handle.cursor_position
        Vector2.new(xpos, ypos)
      end

      def mouse_button_down?(button)
        @handle.mouse_button(button) == :press
      end

      def on_scroll &block
        @scroll_handler = block
      end

      def on_resize &block
        @framebuffer_size_handler = block
      end

      def joystick_buttons(joystick = ::GLFW::JOYSTICK_1)
        @joystick_buttons = poll_all_joysticks_buttons
        @joystick_buttons[joystick]
      end

      def joystick_axes(joystick = ::GLFW::JOYSTICK_1)
        return [] unless joystick_present?(joystick)
        ::GLFW.joystick_axes(joystick)
      end

      def on_joystick_button_pressed &block
        @joystick_button_press_handler = block
      end

      def on_joystick_button_released &block
        @joystick_button_release_handler = block
      end

      def joystick_present?(joystick = ::GLFW::JOYSTICK_1)
        ::GLFW.joystick_present?(joystick)
      end

      def joystick_button_down?(button, joystick = ::GLFW::JOYSTICK_1)
        @joystick_buttons[joystick][button]
      end

      def joystick_name(joystick = ::GLFW::JOYSTICK_1)
        ::GLFW.joystick_name(joystick)
      end

      def set_mouselock(value)
        if value
          @handle.set_input_mode(::GLFW::CURSOR, ::GLFW::CURSOR_DISABLED)
        else
          @handle.set_input_mode(::GLFW::CURSOR, ::GLFW::CURSOR_NORMAL)
        end
      end

      private

      def poll_all_joysticks_buttons
        (::GLFW::JOYSTICK_1..::GLFW::JOYSTICK_LAST).map do |joystick|
          poll_joystick_buttons(joystick)
        end
      end

      def poll_joystick_buttons(joystick)
        return nil unless joystick_present?(joystick)
        ::GLFW.joystick_buttons(joystick).map { |e| e.nonzero? }
      end

      def poll_joystick_events
        new_joystick_buttons = poll_all_joysticks_buttons
        new_joystick_buttons.each_with_index do |buttons, joystick|
          poll_single_joystick_events(joystick, buttons)
        end
        @joystick_buttons = new_joystick_buttons
      end

      def poll_single_joystick_events(joystick, buttons)
        return if buttons.nil?
        buttons.each_with_index do |pressed, button|
          fire_joystick_button_event(joystick, button, pressed)
        end
      end

      def fire_joystick_button_event(joystick, button, pressed)
        if !@joystick_buttons[joystick][button] && pressed
          @joystick_button_press_handler.call(joystick, button) unless @joystick_button_press_handler.nil?
        elsif @joystick_buttons[joystick][button] && !pressed
          @joystick_button_release_handler.call(joystick, button) unless @joystick_button_release_handler.nil?
        end
      end
    end
  end
end
