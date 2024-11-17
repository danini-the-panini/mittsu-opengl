require 'mittsu/opengl/shader/uniforms_utils'
require 'mittsu/opengl/shader/uniforms_lib'
require 'mittsu/opengl/shader/chunk'
require 'mittsu/opengl/shader/rbsl_loader'

module Mittsu
  class OpenGL::Shader
    module Lib
      class Instance
        attr_accessor :uniforms, :vertex_shader, :fragment_shader
        def initialize(options = {})
          @uniforms = options.fetch(:uniforms)
          @vertex_shader = options.fetch(:vertex_shader)
          @fragment_shader = options.fetch(:fragment_shader)
        end
    
        def self.load_from_file(name)
          Instance.new(
            uniforms: RBSLLoader.load_uniforms(File.read(File.join(__dir__, 'lib', name, "#{name}_uniforms.rbslu")), UniformsLib),
            vertex_shader: RBSLLoader.load_shader(File.read(File.join(__dir__, 'lib', name, "#{name}_vertex.rbsl")), Chunk),
            fragment_shader: RBSLLoader.load_shader(File.read(File.join(__dir__, 'lib', name, "#{name}_fragment.rbsl")), Chunk)
          )
        end
      end
      private_constant :Instance
  
      SHADER_LIB_HASH = Hash.new { |h, k|
        h[k] = Instance.load_from_file(k.to_s)
      }
  
      def self.create_shader(id, options={})
        shader = self[id]
        {
          uniforms: UniformsUtils.clone(shader.uniforms),
          vertex_shader: shader.vertex_shader,
          fragment_shader: shader.fragment_shader
        }.merge(options)
      end
  
      def self.[](id)
        SHADER_LIB_HASH[id]
      end
    end
  end
end
