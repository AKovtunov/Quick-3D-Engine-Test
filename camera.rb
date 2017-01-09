class Camera
  attr_reader :angles
  def initialize(window)
    @window = window
    @position, @target, @angles = Vector3.new, Vector3.new, Vector3.new(10.0, 90.0, 0.0)
    @distance = 80.0
    @height = 24.0
    @fovy = 45.0
    @rotation_speed = 3.5
    @max_angle = 40.0
    read_setup_file
  end

  def read_setup_file
    File.open('setup.ini', 'r').readlines.each do |line|
      infos = line.chomp.split(':')
      @fovy = infos[1].to_f if infos[0] == 'fovy'
      @distance = infos[1].to_f if infos[0] == 'distance'
      @height = infos[1].to_f if infos[0] == 'height'
      @angles.x = infos[1].to_f if infos[0] == 'vAngle'
      @rotation_speed = infos[1].to_f if infos[0] == 'rotation_speed'
      @max_angle = infos[1].to_f if infos[0] == 'max_angle'
    end
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
    if @target_element
      @target.x = @target_element.x
      @target.y = @target_element.y + @height
      @target.z = @target_element.z
    end

    @angles.y += @rotation_speed if Gosu::button_down?(Gosu::KbRight)
    @angles.y -= @rotation_speed if Gosu::button_down?(Gosu::KbLeft)
    @angles.x += @rotation_speed if Gosu::button_down?(Gosu::KbUp)
    @angles.x -= @rotation_speed if Gosu::button_down?(Gosu::KbDown)
    @angles.x = -@max_angle if @angles.x < -@max_angle
    @angles.x = @max_angle if @angles.x > @max_angle

    @position.x = @target.x + @distance * Math::cos(@angles.y.to_rad)
    @position.z = @target.z + @distance * Math::sin(@angles.y.to_rad)
    @position.y = @target.y + @distance * Math::sin(@angles.x.to_rad)
  end

  def look
    opengl_setup
    update_position
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(@fovy, @window.width.to_f / @window.height.to_f, 1.0, 1000.0)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(@position.x, @position.y, @position.z, @target.x, @target.y, @target.z, 0, 1, 0)
  end
end
