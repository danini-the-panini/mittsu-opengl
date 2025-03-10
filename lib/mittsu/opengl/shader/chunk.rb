module Mittsu
  class OpenGL::Shader
    Chunk = Hash.new do |chunks, key|
      file_name = "#{key.to_s}.glsl"
      file_path = File.join(__dir__, 'chunks', file_name)
      chunk = File.read(file_path)
      # chunk = "// #{chunk_name}\n#{chunk}"
      chunks[key] = chunk
    end
  end
end
