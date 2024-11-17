require_relative './example_helper'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)

renderer = Mittsu::OpenGL::Renderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: '19 Mesh Face Material Example'

geometry = Mittsu::BoxGeometry.new(1.0, 1.0, 1.0)
material = Mittsu::MeshFaceMaterial.new([
  Mittsu::MeshBasicMaterial.new(color: 0x0046AD), # blue
  Mittsu::MeshBasicMaterial.new(color: 0x009B48), # green
  Mittsu::MeshBasicMaterial.new(color: 0xFFFFFF), # white
  Mittsu::MeshBasicMaterial.new(color: 0xFFD500), # yellow
  Mittsu::MeshBasicMaterial.new(color: 0xF55500), # orange
  Mittsu::MeshBasicMaterial.new(color: 0xB71234), # red
])
cube = Mittsu::Mesh.new(geometry, material)
scene.add(cube)

camera.position.z = 5.0

renderer.window.on_resize do |width, height|
  renderer.set_viewport(0, 0, width, height)
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
  cube.rotation.x += 0.1
  cube.rotation.y += 0.1
  renderer.render(scene, camera)
end
