module Mittsu
  class OpenGL::Shader
    attr_reader :shader

    def initialize(type, string, renderer)
      @renderer = renderer
      @shader = gl.create_shader(type)
      # filename = type == GL::VERTEX_SHADER ? 'vertex.glsl' : 'fragment.glsl'
      # File.write filename, string

      gl.shader_source(@shader, string)
      gl.compile_shader(@shader)

      if !compile_status
        puts "ERROR: Mittsu::OpenGL::Shader: Shader couldn't compile"
      end

      log_info = shader_info_log
      if !log_info.empty?
        puts "WARNING: Mittsu::OpenGL::Shader: GL.GetShaderInfoLog, #{log_info}"
        puts add_line_numbers(string)
      end
    end

    def gl
      @renderer.gl
    end

    private

    def compile_status
      gl.get_shaderiv @shader, GL::COMPILE_STATUS
    end

    def shader_info_log
      length = gl.get_shaderiv @shader, GL::INFO_LOG_LENGTH
      gl.get_shader_info_log @shader, length
    end

    def add_line_numbers(string)
      string.split("\n").each_with_index.map { |line, i|
        line_number = "#{i + 1}".rjust(4, ' ')
        "#{line_number}: #{line}"
      }.join("\n")
    end
  end
end
