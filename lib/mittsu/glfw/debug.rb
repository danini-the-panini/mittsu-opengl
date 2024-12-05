require 'glfw'

OriginalGLFW = ::GLFW

module GLFWDebug

  OriginalGLFW.constants.each do |c|
    const_set c, OriginalGLFW.const_get(c)
  end

  class << self
    def load_lib(*args)
      OriginalGLFW.load_lib(*args)
    end

    def method_missing(m, *args, **kwargs, &block)
      argstr = args.map { |s| s.inspect[0..20] }
      kwargstr = kwargs.map { |k, v| "#{k}: #{v.inspect[0..20]}" }
      print "GLFW.#{m}(#{[*argstr, *kwargstr].join(', ')})"
      r = OriginalGLFW.send(m, *args, **kwargs, &block)
      ret = r ? '' : " => #{r}"
      puts "#{ret} (#{caller[0]})"
      r
    end
  end
end

GLFW = GLFWDebug
