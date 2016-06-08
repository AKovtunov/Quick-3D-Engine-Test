require 'opengl'
require 'glu'
require 'gosu'
include Gl, Glu

require_relative 'utils.rb'
require_relative 'patches.rb'
require_relative 'camera.rb'
require_relative 'character.rb'

class Window < Gosu::Window
  attr_reader :camera
  def initialize
    super(640, 480, false)
    self.caption = "another 3D engine"
    @character = PlayableCharacter.new(self, 'chara_1')
    @camera = Camera.new(self)
    @camera.set_target(@character.position)

    # temp
    @model = ObjModel.new('gfx/models/model_1.obj')
    @textures = GLTexture.new('gfx/textures.png')
  end

  def button_down(id)
    exit if id == Gosu::KbEscape
    @camera.read_setup_file if id == Gosu::KbF5
  end

  def update
    @character.update
  end

  def draw
    gl do
      @camera.look
      @character.draw
      @model.draw(@textures)
    end
  end
end

Window.new.show
