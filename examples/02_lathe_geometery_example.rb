require_relative './example_helper'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)

renderer = Mittsu::OpenGL::Renderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: '02 Lathe geometry Example'

points = 10.times.map do |i|
  Mittsu::Vector2.new(Math.sin(i.to_f * 0.2) * 10.0 + 5.0, (i.to_f - 5.0) * 2.0)
end

geometry = Mittsu::LatheGeometry.new(points, 30, 0.0, Math::PI*1.1)
material = Mittsu::MeshPhongMaterial.new(color: 0x00ff00, side: Mittsu::DoubleSide)
cube = Mittsu::Mesh.new(geometry, material)
scene.add(cube)

box_geometry = Mittsu::BoxGeometry.new(1.0, 1.0, 1.0)
room_material = Mittsu::MeshPhongMaterial.new(color: 0xffffff)
room_material.side = Mittsu::BackSide
room = Mittsu::Mesh.new(box_geometry, room_material)
room.scale.set(10.0, 10.0, 10.0)
scene.add(room)

light = Mittsu::DirectionalLight.new(0xffffff, 0.5) # white, half intensity
light.position.set(0.6, 0.9, 0.5)
light_object = Mittsu::Object3D.new
light_object.add(light)
scene.add(light_object)

camera.position.z = 5.0

renderer.window.on_resize do |width, height|
  renderer.set_size(width, height)
  camera.aspect = width.to_f / height.to_f
  camera.update_projection_matrix
end

renderer.window.on_key_typed do |key|
  case key
  when GLFW::KEY_SPACE
    renderer.take_screenshot("screenshot.png")
  end
end

renderer.window.run do
  cube.rotation.x += 0.01
  cube.rotation.y -= 0.01

  renderer.render(scene, camera)
end
