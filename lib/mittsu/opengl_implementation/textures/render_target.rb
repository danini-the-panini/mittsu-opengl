module Mittsu
  class RenderTarget < Texture
    attr_writer :renderer

    alias :original_clone :clone
    def clone
      original_clone.tap do |tmp|
        tmp.renderer = @renderer
      end
    end

    def setup_buffers
      return unless @framebuffer.nil?

      # TODO: when OpenGLRenderTargetCube exists
      is_cube = false # render_target.is_a? OpenGLRenderTargetCube

      @depth_buffer = true if @depth_buffer.nil?
      @stencil_buffer = true if @stencil_buffer.nil?

      add_event_listener(:dispose, @renderer.method(:on_render_target_dispose))

      @opengl_texture = gl.gen_texture

      @renderer.info[:memory][:textures] += 1

      # Setup texture, create render and frame buffers

      is_target_power_of_two = Math.power_of_two?(@width) && Math.power_of_two?(@height)
      gl_format = GL::MITTSU_PARAMS[@format]
      gl_type = GL::MITTSU_PARAMS[@type]

      if is_cube
        # TODO
      else
        @framebuffer = gl.gen_framebuffer

        if @share_depth_from
          @renderbuffer = share_depth_from.renderbuffer
        else
          @renderbuffer = gl.gen_renderbuffer
        end

        gl.bind_texture(GL::TEXTURE_2D, @opengl_texture)
        set_parameters(GL::TEXTURE_2D, is_target_power_of_two)

        gl.tex_image_2d(GL::TEXTURE_2D, 0, gl_format, @width, @height, 0, gl_format, gl_type, nil)

        setup_framebuffer(GL::TEXTURE_2D)

        if @share_depth_from
          if @depth_buffer && !@stencil_buffer
            gl.framebuffer_renderbuffer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::RENDERBUFFER, @renderbuffer)
          elsif @depth_buffer && @stencil_buffer
            gl.framebuffer_renderbuffer(GL::FRAMEBUFFER, GL::DEPTH_STENCIL_ATTACHMENT, GL::RENDERBUFFER, @renderbuffer)
          end
        else
          setup_renderbuffer
        end

        gl.generate_mipmap(GL::TEXTURE_2D) if is_target_power_of_two
      end

      # Release everything

      if is_cube
        # TODO
      else
        gl.bind_texture(GL::TEXTURE_2D, 0)
      end

      gl.bind_renderbuffer(GL::RENDERBUFFER, 0)
      gl.bind_framebuffer(GL::FRAMEBUFFER, 0)
    end

    def use
      gl.bind_framebuffer(GL::FRAMEBUFFER, @framebuffer)
      gl.viewport(0, 0, @width, @height)
    end

    def dispose
      dispatch_event(type: :dispose)
    end

    def update_mipmap
      return if !@generate_mipmaps || @min_filter == NearestFilter || @min_filter == LinearFilter
      # TODO: when OpenGLRenderTargetCube exists
  		# 	GL.BindTexture(GL::TEXTURE_CUBE_MAP, @opengl_texture)
  		# 	GL.GenerateMipmap(GL::TEXTURE_CUBE_MAP)
  		# 	GL.BindTexture(GL::TEXTURE_CUBE_MAP, nil)
			gl.bind_texture(GL::TEXTURE_2D, @opengl_texture)
			gl.generate_mipmap(GL::TEXTURE_2D)
			gl.bind_texture(GL::TEXTURE_2D, nil)
    end

    private

    def setup_framebuffer(texture_target)
      gl.bind_framebuffer(GL::FRAMEBUFFER, @framebuffer)
      gl.framebuffer_texture_2d(GL::FRAMEBUFFER, GL::COLOR_ATTACHMENT0, texture_target, @opengl_texture, 0)
    end

    def setup_renderbuffer
      gl.bind_renderbuffer(GL::RENDERBUFFER, @renderbuffer)

      if @depth_buffer && !@stencil_buffer
        gl.renderbuffer_storage(GL::RENDERBUFFER, GL::DEPTH_COMPONENT16, @width, @height)
        gl.framebuffer_renderbuffer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::RENDERBUFFER, @renderbuffer)

        # TODO: investigate this (?):
    		# THREE.js - For some reason this is not working. Defaulting to RGBA4.
    		# } else if ( ! renderTarget.depthBuffer && renderTarget.stencilBuffer ) {
        #
    		# 	_gl.renderbufferStorage( _gl.RENDERBUFFER, _gl.STENCIL_INDEX8, renderTarget.width, renderTarget.height );
    		# 	_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.STENCIL_ATTACHMENT, _gl.RENDERBUFFER, renderbuffer );
      elsif @depth_buffer && @stencil_buffer
        gl.renderbuffer_storage(GL::RENDERBUFFER, GL::DEPTH_STENCIL, @width, @height)
        gl.framebuffer_renderbuffer(GL::FRAMEBUFFER, GL::DEPTH_STENCIL_ATTACHMENT, GL::RENDERBUFFER, @renderbuffer)
      else
        gl.renderbuffer_storage(GL::RENDERBUFFER, GL::RGBA4, @width, @height)
      end
    end
  end
end
