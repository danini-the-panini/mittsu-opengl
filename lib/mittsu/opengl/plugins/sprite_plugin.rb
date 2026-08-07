module Mittsu
  class SpritePlugin
    include OpenGL::Helper

    VERTICES = TypedArray::Float32.new([
      -0.5, -0.5, 0.0, 0.0,
       0.5, -0.5, 1.0, 0.0,
       0.5,  0.5, 1.0, 1.0,
      -0.5,  0.5, 0.0, 1.0
    ])

    FACES = TypedArray::Uint16.new([
      0, 1, 2,
      0, 2, 3
    ])

    def initialize(renderer, sprites)
      @renderer = renderer
      @sprites = sprites
      @program = nil

      # for decomposing matrixWorld
      @sprite_position = Vector3.new
      @sprite_rotation = Quaternion.new
      @sprite_scale = Vector3.new
    end

    def gl
      @renderer.gl
    end

    def render(scene, camera)
      return if @sprites.empty?

      init if @program.nil?
      setup_gl_for_render(camera)
      setup_fog(scene)

      update_positions_and_sort(camera)

      render_all_sprites(scene)

      gl.enable(GL::CULL_FACE)
      @renderer.reset_gl_state
    end

    private

    def init
      create_vertex_array_object
      create_program

      init_attributes
      init_uniforms

      # TODO: canvas texture??
    end

    def create_vertex_array_object
      @vertex_array_object = gl.gen_vertex_array
      gl.bind_vertex_array(@vertex_array_object)

      @vertex_buffer = gl.gen_buffer
      @element_buffer = gl.gen_buffer

      gl.bind_buffer(GL::ARRAY_BUFFER, @vertex_buffer)
      gl.buffer_data(GL::ARRAY_BUFFER, VERTICES, GL::STATIC_DRAW)

      gl.bind_buffer(GL::ELEMENT_ARRAY_BUFFER, @element_buffer)
      gl.buffer_data(GL::ELEMENT_ARRAY_BUFFER, FACES, GL::STATIC_DRAW)
    end

    def create_program
      @program = gl.create_program

      vertex_shader = OpenGL::Shader.new(GL::VERTEX_SHADER, File.read(File.join(__dir__, 'sprite_vertex.glsl')), @renderer)
      fragment_shader = OpenGL::Shader.new(GL::FRAGMENT_SHADER, File.read(File.join(__dir__, 'sprite_fragment.glsl')), @renderer)

      gl.attach_shader(@program, vertex_shader.shader)
      gl.attach_shader(@program, fragment_shader.shader)

      gl.link_program(@program)
    end

    def init_attributes
      @attributes = {
        position: gl.get_attrib_location(@program, 'position'),
        uv: gl.get_attrib_location(@program, 'uv')
      }
    end

    def init_uniforms
      @uniforms = {
        uvOffset: gl.get_uniform_location(@program, 'uvOffset'),
        uvScale: gl.get_uniform_location(@program, 'uvScale'),

        rotation: gl.get_uniform_location(@program, 'rotation'),
        scale: gl.get_uniform_location(@program, 'scale'),

        color: gl.get_uniform_location(@program, 'color'),
        map: gl.get_uniform_location(@program, 'map'),
        opacity: gl.get_uniform_location(@program, 'opacity'),

        modelViewMatrix: gl.get_uniform_location(@program, 'modelViewMatrix'),
        projectionMatrix: gl.get_uniform_location(@program, 'projectionMatrix'),

        fogType: gl.get_uniform_location(@program, 'fogType'),
        fogDensity: gl.get_uniform_location(@program, 'fogDensity'),
        fogNear: gl.get_uniform_location(@program, 'fogNear'),
        fogFar: gl.get_uniform_location(@program, 'fogFar'),
        fogColor: gl.get_uniform_location(@program, 'fogColor'),

        alphaTest: gl.get_uniform_location(@program, 'alphaTest')
      }
    end

    def painter_sort_stable(a, b)
      if a.z != b.z
        b.z - a.z
      else
        b.id - a.id
      end
    end

    def setup_gl_for_render(camera)
      gl.use_program(@program)

      gl.disable(GL::CULL_FACE)
      gl.enable(GL::BLEND)

      gl.bind_vertex_array(@vertex_array_object)

      gl.enable_vertex_attrib_array(@attributes[:position])
      gl.enable_vertex_attrib_array(@attributes[:uv])

      gl.bind_buffer(GL::ARRAY_BUFFER, @vertex_buffer)

      gl.vertex_attrib_pointer(@attributes[:position], 2, GL::FLOAT, false, 2 * 8, 0)
      gl.vertex_attrib_pointer(@attributes[:uv], 2, GL::FLOAT, false, 2 * 8, 8)

      gl.bind_buffer(GL::ELEMENT_ARRAY_BUFFER, @element_buffer)

      gl.uniform_matrix4fv(@uniforms[:projectionMatrix], false, camera.projection_matrix.elements)

      gl.active_texture(GL::TEXTURE0)
      gl.uniform1i(@uniforms[:map], 0)
    end

    def setup_fog(scene)
      @old_fog_type = 0
      @scene_fog_type = 0
      fog = scene.fog

      if fog
        gl.uniform3f(@uniforms[:fogColor], fog.color.r, fog.color.g, fog.color.b)

        if fog.is_a?(Fog)
          gl.uniform1f(@uniforms[:fogNear], fog.near)
          gl.uniform1f(@uniforms[:fogFar], fog.far)

          gl.uniform1i(@uniforms[:fogType], 1)
          @old_fog_type = 1
          @scene_fog_type = 1
        elsif fog.is_a?(FogExp2)
          gl.uniform1f(@uniforms[:fogDensity], fog.density)

          gl.uniform1i(@uniforms[:fogType], 2)
          @old_fog_type = 2
          @scene_fog_type = 2
        end
      else
        gl.uniform1i(@uniforms[:fogType], 0)
        @old_fog_type = 0
        @scene_fog_type = 0
      end
    end

    def update_positions_and_sort(camera)
      @sprites.each do |sprite|
        sprite.model_view_matrix.multiply_matrices(camera.matrix_world_inverse, sprite.matrix_world)
        sprite.z = -sprite.model_view_matrix.elements[14]
      end

      @sprites.sort!(&self.method(:painter_sort_stable))
    end

    def render_all_sprites(scene)
      @sprites.each do |sprite|
        material = sprite.material

        set_fog_uniforms(material, scene)
        set_uv_uniforms(material)
        set_color_uniforms(material)
        set_transform_uniforms(sprite)
        set_blend_mode(material)

        # set texture
        if material.map && material.map.image && material.map.image.width
          material.map.set(0, @renderer)
        else
          # TODO: canvas texture?
          # texture.set(0, @renderer)
        end

        # draw elements
        gl.draw_elements(GL::TRIANGLES, 6, GL::UNSIGNED_SHORT, 0)
      end
    end

    def set_fog_uniforms(material, scene)
      fog_type = 0

      if scene.fog && material.fog
        fog_type = @scene_fog_type
      end

      if @old_fog_type != fog_type
        gl.uniform1(@uniforms[:fogType], fog_type)
        @old_fog_type = fog_type
      end
    end

    def set_uv_uniforms(material)
      if !material.map.nil?
        gl.uniform2f(@uniforms[:uvOffset], material.map.offset.x, material.map.offset.y)
        gl.uniform2f(@uniforms[:uvScale], material.map.repeat.x, material.map.repeat.y)
      else
        gl.uniform2f(@uniforms[:uvOffset], 0.0, 0.0)
        gl.uniform2f(@uniforms[:uvScale], 1.0, 1.0)
      end
    end

    def set_color_uniforms(material)
      gl.uniform1f(@uniforms[:opacity], material.opacity)
      gl.uniform3f(@uniforms[:color], material.color.r, material.color.g, material.color.b)
      gl.uniform1f(@uniforms[:alphaTest], material.alpha_test)
    end

    def set_transform_uniforms(sprite)
      gl.uniform_matrix4fv(@uniforms[:modelViewMatrix], false, sprite.model_view_matrix.elements)

      sprite.matrix_world.decompose(@sprite_position, @sprite_rotation, @sprite_scale)

      gl.uniform1f(@uniforms[:rotation], sprite.material.rotation)
      gl.uniform2fv(@uniforms[:scale], TypedArray::Float32.new([@sprite_scale.x, @sprite_scale.y]))
    end

    def set_blend_mode(material)
      @renderer.state.set_blending(material.blending, material.blend_equation, material.blend_src, material.blend_dst)
      @renderer.state.set_depth_test(material.depth_test)
      @renderer.state.set_depth_write(material.depth_write)
    end
  end
end
