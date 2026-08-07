module RubyGL
  Context_ = Context
  class DebugContext
    def initialize
      @gl = Context_.new
    end

    def method_missing(name, *args)
      @gl.send(name, *args).tap do
        check_error
      end
    end

    def respond_to_missing?(name)
      @gl.respond_to?(name)
    end

    def check_error
      case @gl.get_error
        when RubyGL::INVALID_ENUM
         raise Error, "INVALID_ENUM:An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag."
        when RubyGL::INVALID_VALUE
         raise Error, "INVALID_VALUE:A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag."
        when RubyGL::INVALID_OPERATION
         raise Error, "INVALID_OPERATION:The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag."
        when RubyGL::INVALID_FRAMEBUFFER_OPERATION
         raise Error, "INVALID_FRAMEBUFFER_OPERATION:The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag."
        when RubyGL::OUT_OF_MEMORY
         raise Error, "OUT_OF_MEMORY:There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded."
        when RubyGL::STACK_UNDERFLOW
         raise Error, "STACK_UNDERFLOW:An attempt has been made to perform an operation that would cause an internal stack to underflow."
        when RubyGL::STACK_OVERFLOW
         raise Error, "STACK_OVERFLOW:An attempt has been made to perform an operation that would cause an internal stack to overflow."
      end
    end
  end

  Context = DebugContext
end
