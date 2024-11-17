require 'mittsu/generic_lib'

module Mittsu
  module OpenGL::Lib
    extend GenericLib

    class Linux < GenericLib::Linux
      def initialize(loader = Linux)
        @loader = loader
      end
    end

    class Windows < GenericLib::Base
    end

    class MacOS < GenericLib::Base
    end
  end
end
