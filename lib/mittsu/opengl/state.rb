module Mittsu
  class OpenGL::State
    attr_reader :gl

    def initialize(gl)
      @gl = gl
      @new_attributes = Array.new(16) # Uint8Array
      @enabled_attributes = Array.new(16) # Uint8Array

      @current_blending = nil
      @current_blend_equation = nil
      @current_blend_src = nil
      @current_blend_dst = nil
      @current_blend_equation_alpha = nil
      @current_blend_src_alpha = nil
      @current_blend_dst_alpha = nil

      @current_depth_test = nil
      @current_depth_write = nil

      @current_color_write = nil

      @current_double_sided = nil
      @current_flip_sided = nil

      @current_line_width = nil

      @current_polygon_offset = nil
      @current_polygon_offset_factor = nil
      @current_polygon_offset_units = nil
    end

    def init_attributes
      @new_attributes.length.times do |i|
        @new_attributes[i] = false
      end
    end

    def enable_attribute(attribute)
      gl.enable_vertex_attrib_array(attribute)
      @new_attributes[attribute] = true

      if !@enabled_attributes[attribute]
        # gl.enable_vertex_attrib_array(attribute)
        @enabled_attributes[attribute] = true
      end
    end

    def disable_unused_attributes
      @enabled_attributes.length.times do |i|
        if @enabled_attributes[i] && !@new_attributes[i]
          gl.disable_vertex_attrib_array(i)
          @enabled_attributes[i] = false
        end
      end
    end

    def set_blending(blending, blend_equation = nil, blend_src = nil, blend_dst = nil, blend_equation_alpha = nil, blend_src_alpha = nil, blend_dst_alpha = nil)
      if blending != @current_blending
        case blending
        when NoBlending
          gl.disable(GL::BLEND)
        when AdditiveBlending
          gl.enable(GL::BLEND)
          gl.blend_equation(GL::FUNC_ADD)
          gl.blend_func(GL::SRC_ALPHA, GL::ONE)
        when SubtractiveBlending
          # TODO: Find blendFuncSeparate() combination ???
          gl.enable(GL::BLEND)
          gl.blend_equation(GL::FUNC_ADD)
          gl.blend_func(GL::ZERO, GL::ONE_MINUS_SRC_COLOR)
        when MultiplyBlending
          # TODO: Find blendFuncSeparate() combination ???
          gl.enable(GL::BLEND)
          gl.blend_equation(GL::FUNC_ADD)
          gl.blend_func(GL::ZERO, GL::ONE_MINUS_SRC_COLOR)
        when CustomBlending
          gl.enable(GL::BLEND)
        else
          gl.enable(GL::BLEND)
          gl.blend_equation_separate(GL::FUNC_ADD, GL::FUNC_ADD)
          gl.blend_func_separate(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA, GL::ONE, GL::ONE_MINUS_SRC_ALPHA)
        end

        @current_blending = blending
      end

      if blending == CustomBlending
        blend_equation_alpha ||= blend_equation
        blend_src_alpha ||= blend_src
        blend_dst_alpha ||= blend_dst

        if blend_equation != @current_blend_equation || blend_equation_alpha != @current_blend_equation_alpha
          gl.blend_equation_separate(GL::MITTSU_PARAMS[blend_equation], GL::MITTSU_PARAMS[blend_equation_alpha])

          @current_blend_equation = blend_equation
          @current_blend_equation_alpha = blend_equation_alpha
        end

        if blend_src != @current_blend_src || blend_dst != @current_blend_dst || blend_src_alpha != @current_blend_src_alpha || blend_dst_alpha != @current_blend_dst_alpha
          gl.blend_func_separate(GL::MITTSU_PARAMS[blend_src], GL::MITTSU_PARAMS[blend_dst], GL::MITTSU_PARAMS[blend_src_alpha], GL::MITTSU_PARAMS[blend_dst_alpha])

          @current_blend_src = nil
          @current_blend_dst = nil
          @current_blend_src_alpha = nil
          @current_blend_dst_alpha = nil
        end
      else
        @current_blend_equation = nil
        @current_blend_src = nil
        @current_blend_dst = nil
        @current_blend_equation_alpha = nil
        @current_blend_src_alpha = nil
        @current_blend_dst_alpha = nil
      end
    end

    def set_depth_test(depth_test)
      if @current_depth_test != depth_test
        if depth_test
          gl.enable(GL::DEPTH_TEST)
        else
          gl.disable(GL::DEPTH_TEST)
        end

        @current_depth_test = depth_test
      end
    end

    def set_depth_write(depth_write)
      if @current_depth_write != depth_write
        gl.depth_mask(depth_write)
        @current_depth_write = depth_write
      end
    end

    def set_color_write(color_write)
      if @current_color_write != color_write
        gl.color_mask(color_write, color_write, color_write, color_write)
        @current_color_write = color_write
      end
    end

    def set_double_sided(double_sided)
      if @current_double_sided != double_sided
        if double_sided
          gl.disable(GL::CULL_FACE)
        else
          gl.enable(GL::CULL_FACE)
        end

        @current_double_sided = double_sided
      end
    end

    def set_flip_sided(flip_sided)
      if @current_flip_sided != flip_sided
        if flip_sided
          gl.front_face(GL::CW)
        else
          gl.front_face(GL::CCW)
        end

        @current_flip_sided = flip_sided
      end
    end

    def set_line_width(width)
      if width != @current_line_width
        gl.line_width(width)
        @current_line_width = width
      end
    end

    def set_polygon_offset(polygon_offset, factor, units)
      if @current_polygon_offset != polygon_offset
        if polygon_offset
          gl.enable(GL::POLYGON_OFFSET_FILL)
        else
          gl.disable(GL::POLYGON_OFFSET_FILL)
        end

        @current_polygon_offset = polygon_offset
      end

      if polygon_offset && (@current_polygon_offset_factor != factor || @current_polygon_offset_units != units)
        gl.polygon_offset(factor, units)

        @current_polygon_offset_factor = factor
        @current_polygon_offset_units = units
      end
    end

    def reset
      @enabled_attributes.length.times do |i|
        @enabled_attributes[i] = false
      end

      @current_blending = nil
      @current_depth_test = nil
      @current_depth_write = nil
      @current_color_write = nil
      @current_double_sided = nil
      @current_flip_sided = nil
    end
  end
end
