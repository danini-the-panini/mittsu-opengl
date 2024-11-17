require 'mittsu/opengl/material_basics'

module Mittsu
  class MeshBasicMaterial
    include OpenGL::MaterialBasics

    def refresh_uniforms(uniforms)
      refresh_uniforms_basic(uniforms)
    end

    protected

    def init_shader
      @shader = OpenGL::Shader::Lib.create_shader(shader_id)
    end

    def shader_id
      :basic
    end
  end
end
