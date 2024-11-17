ENV["MITTSU_ENV"] = 'test'

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start do
  add_filter "/test/"
  add_group 'GLFW', 'lib/mittsu/glfw'
  add_group 'Renderer', 'lib/mittsu/opengl'
  add_group 'Core', 'lib/mittsu/opengl_implementation/core'
  add_group 'Lights', 'lib/mittsu/opengl_implementation/lights'
  add_group 'Materials', 'lib/mittsu/opengl_implementation/materials'
  add_group 'Objects', 'lib/mittsu/opengl_implementation/objects'
  add_group 'Scenes', 'lib/mittsu/opengl_implementation/scenes'
  add_group 'Textures', 'lib/mittsu/opengl_implementation/textures'
end

require "minitest/reporters"
REPORTER = "#{ENV['MINITEST_REPORTER'] || 'Progress'}Reporter"
if !Minitest::Reporters.const_defined?(REPORTER)
  puts "WARNING: Reporter \"#{REPORTER}\" not found, using default"
  Minitest::Reporters.use!
else
  Minitest::Reporters.use! Minitest::Reporters.const_get(REPORTER).new
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'minitest'
Dir[__dir__ + '/support/*.rb'].each {|file| require file }
require 'mittsu/opengl'

class Minitest::Test
  def assert_color_equal expected, actual
    assert_in_delta expected.r, actual.r
    assert_in_delta expected.g, actual.g
    assert_in_delta expected.b, actual.b
  end
end

require 'minitest/autorun'
