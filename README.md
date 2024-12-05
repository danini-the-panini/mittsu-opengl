# Mittsu OpenGL Renderer

[![Gem Version](https://badge.fury.io/rb/mittsu-opengl.svg)](https://badge.fury.io/rb/mittsu-opengl)
[![Test Coverage](https://api.codeclimate.com/v1/badges/dd4137d5afd04077f4ec/test_coverage)](https://codeclimate.com/github/danini-the-panini/mittsu-opengl/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/dd4137d5afd04077f4ec/maintainability)](https://codeclimate.com/github/danini-the-panini/mittsu-opengl/maintainability)
[![Build Status](https://github.com/danini-the-panini/mittsu-opengl/workflows/Build/badge.svg)](https://github.com/danini-the-panini/mittsu-opengl/actions?query=workflow%3A%22Build%22)

OpenGL renderer for Mittsu

OpenGL 3 renderer for Mittsu using GLFW for context creation.

## GIFs!

![Normal-mapped Earth](https://cloud.githubusercontent.com/assets/1171825/18411863/45328540-7781-11e6-986b-6e3f2551c719.gif)
![Point Light](https://cloud.githubusercontent.com/assets/1171825/18411861/4531bb4c-7781-11e6-92b4-b6ebda60e2c9.gif)
![Tank Demo](https://cloud.githubusercontent.com/assets/1171825/18411862/4531fe9a-7781-11e6-9665-b172df1a3645.gif)

(You can find the source for the Tank Demo [here](https://github.com/danini-the-panini/mittsu-tank-demo))

## Installation

Install the prerequisites:

Mittsu depends on Ruby 2.6+, OpenGL 3.3+, and GLFW 3.1+

```bash
# OSX
$ brew install glfw3

# Ubuntu
$ sudo apt install libglfw3

# Fedora
$ sudo dnf install glfw
```

**NOTE:** On Windows, you will have to manually specify the glfw3.dll path in an environment variable
(you can download it [here](http://www.glfw.org/download.html))
```bash
# ex) set MITTSU_LIBGLFW_PATH=C:\Users\username\lib-mingw-w64
> set MITTSU_LIBGLFW_PATH=C:\path\to\glfw3.dll
> ruby your_awesome_mittsu_app.rb
```

Add this line to your application's Gemfile:

```ruby
gem 'mittsu-opengl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mittsu-opengl

## Usage

### tl;dr

Copy-Paste and Run:

```ruby
require 'mittsu-opengl'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

renderer = Mittsu::OpenGL::Renderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Hello, World!'

scene = Mittsu::Scene.new

camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
camera.position.z = 5.0

box = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
  Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
)

scene.add(box)

renderer.window.run do
  box.rotation.x += 0.1
  box.rotation.y += 0.1

  renderer.render(scene, camera)
end
```

### Step by Step

First, we need to require the Mittsu OpenGL renderer in order to use it:
```ruby
require 'mittsu'
```

Then, we'll define some constants to help us with setting up our 3D environment:
```ruby
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f
```

The aspect ratio will be used for setting up the camera later.

Once we have all that we can create the canvas we will use to draw our graphics onto. In Mittsu this is called a renderer. It provides a window and an OpenGL context:

```ruby
renderer = Mittsu::OpenGL::Renderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Hello, World!'
```
This will give us an 800x600 window with the title `Hello, World!`.

Now that we have our canvas, let's start setting up the scene we wish to draw onto it:

```ruby
scene = Mittsu::Scene.new
```

A scene is like a stage where all our 3D objects live and animate.

We can't draw a 3D scene without knowing where we're looking:

```ruby
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
```

This camera has a 75° field-of-view (FOV), the aspect ratio of the window (which we defined earlier), and shows everything between a distance of 0.1 to 1000.0 away from the camera.

The camera starts off at the origin `[0,0,0]` and faces the negative Z-axis. We'll position it somewhere along the positive Z-axis so that it is looking at the center of the scene from a short distance:

```ruby
camera.position.z = 5.0
```

Our scene isn't going to be very exciting if there is nothing in it, so we'll create a box:

```ruby
box = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
  Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
)
```

A `Mesh` in Mittsu is the combination of a `Geometry` (the shape of the object) and a `Material` (the "look" of the object). Here we've created a 1x1x1 box that is colored green.

Box in hand, we make it part of our scene:

```ruby
scene.add(box)
```

Here comes the fun part... the render loop!

```ruby
renderer.window.run do
```

The given block is called every frame. This is where you can tell the renderer what scene to draw, and do any updates to the objects in your scene.

Just to make things a bit more interesting, we'll make the box rotate around its X and Y axes, so that it spins like crazy.

```ruby
box.rotation.x += 0.1
box.rotation.y += 0.1
```

Last but not least, we tell the renderer to draw our scene this frame, which will tell the graphics processor to draw our green box with its updated rotation.

```ruby
renderer.render(scene, camera)
```

Easy peasy! :)

```ruby
end
```

### More Resources

If you just want to see what Mittsu can do and how to do it, take a peek inside the `examples` folder.

### JRuby

JRuby support is still a work in progress. This is mainly due to subtle behavioural differences in Fiddle.

On macOS JRuby must be started with the `-J-XstartOnFirstThread` argument for GLFW to work. This is necessary because most GLFW functions must be called on the main thread and the Cocoa API requires that thread to be the first thread in the process. GLFW windows and the GLFW event loop are incompatible with other window toolkits (such as AWT/Swing or JavaFX).

(Otherwise you have to extract and use the custom `libglfw_async.dylib` from [LWJGL3](https://www.lwjgl.org))

## Contributing

1. Fork it ( https://github.com/danini-the-panini/mittsu-opengl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Thank you for helping me help you help us all. ;)
