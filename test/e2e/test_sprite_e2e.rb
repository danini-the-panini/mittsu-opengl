require 'minitest_helper'

class TestSpriteE2E < Minitest::Test
  def test_that_it_works
    width = 800
    height = 600
    aspect = width.to_f / height.to_f

    scene = Mittsu::Scene.new
    camera = Mittsu::PerspectiveCamera.new(75.0, aspect, 0.1, 1000.0)

    renderer = Mittsu::OpenGL::Renderer.new width: width, height: height, title: 'TestSpriteE2E'

    texture = Mittsu::ImageUtils.load_texture(File.expand_path "../../support/samples/test.png", __FILE__)
    material = Mittsu::SpriteMaterial.new(map: texture)
    sprite = Mittsu::Sprite.new(material)
    scene.add(sprite)

    camera.position.z = 5.0

    renderer.window.run do
      renderer.render(scene, camera)
    end
  end
end
