module Mittsu
  class BufferGeometry
    include OpenGL::GeometryLike

    attr_accessor :initted

    def init
      @initted = true
    end
  end
end
