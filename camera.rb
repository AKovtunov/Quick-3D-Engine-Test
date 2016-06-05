class Camera
  attr_reader :angles
  def initialize(window)
    @window = window
    @position, @target, @angles = Vector3.new, Vector3.new, Vector3.new(30, 90, 0)
    @distance = 128.0
  end

  def opengl_setup
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_DEPTH_TEST)
    glClearColor(0.0, 1.0, 0.0, 0.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    glEnableClientState(GL_NORMAL_ARRAY)
  end

  def set_target(element)
    @target_element = element
  end

  def update_position
    if @target_element != nil
      @target.x = @target_element.x
      @target.y = @target_element.y
      @target.z = @target_element.z
    end

    @position.x = @target.x + @distance * Math::cos(@angles.x * $deg_to_rad)
    @position.z = @target.z + @distance * Math::cos(@angles.x * $deg_to_rad)
    @position.x = @target.x + @distance * Math::cos(@angles.y * $deg_to_rad)
    @position.y = @target.y + @distance * Math::sin(@angles.x * $deg_to_rad)
    @position.z = @target.z + @distance * Math::sin(@angles.y * $deg_to_rad)
  end

  def look
    opengl_setup
    update_position
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, @window.width.to_f / @window.height.to_f, 1.0, 1000.0)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(@position.x, @position.y, @position.z, @target.x, @target.y, @target.z, 0, 1, 0)
  end
end
