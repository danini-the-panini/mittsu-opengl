module Mittsu
  class OpenGL::Buffer < Struct.new(:buffer, :object, :material, :z)
    attr_accessor :render, :transparent, :opaque

    def name
      "BUFFER(#{object.name})"
    end

    def id
      object.id
    end
  end
end
