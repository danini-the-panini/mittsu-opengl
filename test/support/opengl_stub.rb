require 'ruby_gl'

module RubyGL
  Context_ = Context
  class StubContext
    def initialize
      @gl = Context_.new
    end

    def method_missing(name, *args)
      return if @gl.respond_to?(name)
      super
    end

    def respond_to_missing?(name)
      @gl.respond_to?(name)
    end

    def gen_vertex_arrays(n)
      next_va = (@@_GenVertexArrays ||= 1)
      @@_GenVertexArrays += n
      n.times.map { |i| i + next_va }
    end

    def gen_vertex_array
      gen_vertex_arrays(1).first
    end

    def gen_buffers(n)
      next_va = (@@_GenBuffers ||= 1)
      @@_GenBuffers += n
      n.times.map { |i| i + next_va }
    end

    def gen_buffer
      gen_buffers(1).first
    end

    def gen_textures(n)
      next_va = (@@_GenTextures ||= 1)
      @@_GenTextures += n
      n.times.map { |i| i + next_va }
    end

    def gen_texture
      gen_textures(1).first
    end

    def gen_framebuffers(n)
      next_va = (@@_GenFramebuffers ||= 1)
      @@_GenFramebuffers += n
      n.times.map { |i| i + next_va }
    end

    def gen_framebuffer
      gen_framebuffers(1).first
    end

    def gen_renderbuffers(n)
      next_va = (@@_GenRenderbuffers ||= 1)
      @@_GenRenderbuffers += n
      n.times.map { |i| i + next_va }
    end

    def gen_renderbuffer
      gen_renderbuffers(1).first
    end

    def get_booleanv(_)
      true
    end

    def get_doublev(_)
      rand
    end

    def get_floatv(_)
      rand
    end

    def get_integerv(_)
      4096
    end

    def get_shaderiv(_, _)
      4096
    end
    alias :get_programiv :get_shaderiv

    def get_shader_info_log(_, _)
      ""
    end
    alias :get_program_info_log :get_shader_info_log

    def get_error()
      GL::NO_ERROR
    end

    def front_face(mode)
      @@_FrontFace = mode
    end

    def cull_face(mode)
      @@_CullFace = mode
    end

    def enable(cap)
      (@@_Enable ||= {}).tap { |e| e[cap] = true }
    end

    def disable(cap)
      (@@_Enable ||= {}).tap { |e| e[cap] = false }
    end

    def enabled?(cap)
      (@@_Enable ||= {})[cap]
    end

    def gen_lists(_range_)
      _range_
    end

    def render_mode(_mode_)
      0
    end

    def list?(_list_)
      true
    end

    def texture?(_texture_)
      true
    end

    def textures_resident?(_n_, _textures_, _residences_)
      true
    end

    def query?(_id_)
      true
    end

    def buffer?(_buffer_)
      true
    end

    def unmap_buffer(_target_)
      true
    end

    def create_program()
      (@@_CreateProgram ||= 1).tap { @@_CreateProgram += 1 }
    end

    def create_shader(_type_)
      (@@_CreateShader ||= 1).tap { @@_CreateShader += 1 }
    end

    def get_attrib_location(_program_, _name_)
      (@@_GetAttribLocation ||= 1).tap { @@_GetAttribLocation += 1 }
    end

    def get_uniform_location(_program_, _name_)
      (@@_GetUniformLocation ||= 1).tap { @@_GetUniformLocation += 1 }
    end

    def program?(_program_)
      true
    end

    def shader?(_shader_)
      true
    end

    def enabledi?(_target_, _index_)
      true
    end

    def get_frag_fata_location(_program_, _name_)
      (@@_GetFragDataLocation ||= 1).tap { @@_GetFragDataLocation += 1 }
    end

    def renderbuffer?(_renderbuffer_)
      true
    end

    def framebuffer?(_framebuffer_)
      true
    end

    def check_framebuffer_status(_target_)
      GL::FRAMEBUFFER_COMPLETE
    end

    def vertex_array?(_array_)
      true
    end

    def get_uniform_block_index(_program_, _uniformBlockName_)
      (@@_GetUniformBlockIndex ||= 1).tap { @@_GetUniformBlockIndex += 1 }
    end

    def sync?(_sync_)
      true
    end

    def client_wait_sync(_sync_, _flags_, _timeout_)
      GL::ALREADY_SIGNALED
    end

    def get_frag_data_index(_program_, _name_)
      (@@_GetFragDataIndex ||= 1).tap { @@_GetFragDataIndex += 1 }
    end

    def sampler?(_sampler_)
      true
    end

    def get_subroutine_uniform_location(_program_, _shadertype_, _name_)
      (@@_GetSubroutineUniformLocation ||= 1).tap { @@_GetSubroutineUniformLocation += 1 }
    end

    def get_subroutine_index(_program_, _shadertype_, _name_)
      (@@_GetSubroutineIndex ||= 1).tap { @@_GetSubroutineIndex += 1 }
    end

    def transform_feedback?(_id_)
      true
    end

    def create_shader_programv(_type_, _count_, _strings_)
      (@@_CreateShaderProgramv ||= 1).tap { @@_CreateShaderProgramv += 1 }
    end

    def program_pipeline?(_pipeline_)
      true
    end

    def get_program_resource_index(_program_, _programInterface_, _name_)
      (@@_GetProgramResourceIndex ||= 1).tap { @@_GetProgramResourceIndex += 1 }
    end

    def get_program_resource_location(_program_, _programInterface_, _name_)
      (@@_GetProgramResourceLocation ||= 1).tap { @@_GetProgramResourceLocation += 1 }
    end

    def get_program_resource_location_index(_program_, _programInterface_, _name_)
      (@@_GetProgramResourceLocationIndex ||= 1).tap { @@_GetProgramResourceLocationIndex += 1 }
    end

    def get_debug_message_log(_count_, _bufSize_, _sources_, _types_, _ids_, _severities_, _lengths_)
      "DEBUG LOG"
    end

    def unmap_named_buffer(_buffer_)
      true
    end

    def check_named_framebuffer_status(_framebuffer_, _target_)
      GL::FRAMEBUFFER_COMPLETE
    end

    def get_graphics_reset_status()
      GL::NO_ERROR
    end
  end
  Context = StubContext
end
