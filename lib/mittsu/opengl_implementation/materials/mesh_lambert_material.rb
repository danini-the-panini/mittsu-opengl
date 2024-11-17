require 'mittsu/opengl/material_basics'

module Mittsu
  class MeshLambertMaterial
    include OpenGL::MaterialBasics

    def refresh_uniforms(uniforms)
      refresh_uniforms_basic(uniforms)

      uniforms['emissive'].value = emissive

      if wrap_around
        uniforms['wrapRGB'].value.copy(wrap_rgb)
      end
    end

    def needs_view_matrix_uniform?
      true
    end

    def needs_lights?
      true
    end

    def init_shader
      @shader = OpenGL::Shader::Lib.create_shader(shader_id)
    end

    def shader_id
      :lambert
    end
  end
end
