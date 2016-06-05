class Character
  attr_reader :position
  def initialize(window, filename)
    @window = window
    @frames = Gosu::Image.new("gfx/charsets/#{filename}.png", {:retro=>true, :tileable=>true})
    @frame_count = 3
    @orientations = [:S, :SW, :N, :SE, :W, :NW, :E, :NE]
    @orientation = :S
    @frame = 1
    @frame_duration = 150 # milliseconds
    @frame_tick = Gosu::milliseconds
    @left_foot = true # variable used to alternate between feet
    @frame_rect_width = 1.0 / @frame_count
    @frame_rect_width_pixel = @frames.width / @frame_count
    @frame_rect_height = 1.0 / @orientations.size
    @frame_rect_height_pixel = @frames.height / @orientations.size
    @position = Vector3.new(0, 0, 0)
    @angles = Vector3.new(0, 0, 0)
    update_vertex_array
  end

  def update_vertex_array
    # vertices will never change
    @v ||= [-@frame_rect_width_pixel / 2, @frame_rect_height_pixel, 0.0, -@frame_rect_width_pixel / 2, 0.0, 0.0,
      @frame_rect_width_pixel / 2, 0.0, 0.0, @frame_rect_width_pixel / 2, @frame_rect_height_pixel, 0.0]
    # texture vertices calculation
    tex_coord_x = (1.0 / @frame_count) * @frame
    tex_coord_y = 1.0 - ((1.0 / @orientations.size) * @orientations.index(@orientation))
    top_left = @frames.gl_tex_info.get_tex_coord_2d(tex_coord_x, tex_coord_y)
    bottom_left = @frames.gl_tex_info.get_tex_coord_2d(tex_coord_x, tex_coord_y - @frame_rect_height)
    bottom_right = @frames.gl_tex_info.get_tex_coord_2d(tex_coord_x + @frame_rect_width, tex_coord_y - @frame_rect_height)
    top_right = @frames.gl_tex_info.get_tex_coord_2d(tex_coord_x + @frame_rect_width, tex_coord_y)
    @vt = top_left + bottom_left + bottom_right + top_right
  end

  def draw
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)
    glBindTexture(GL_TEXTURE_2D, @frames.gl_tex_info.tex_name)
      glPushMatrix
        glTranslate(@position.x, @position.y, @position.z)
        glRotate(90.0 - @angles.y, 0, 1, 0)
    		glVertexPointer(3, GL_FLOAT, 0, @v)
    		glTexCoordPointer(2, GL_FLOAT, 0, @vt)
    		glDrawArrays(GL_TRIANGLE_FAN, 0, @v.size / 3)
      glPopMatrix
    glDisable(GL_ALPHA_TEST)
  end

  def update
    @angles = @window.camera.angles
  end
end

class PlayableCharacter < Character
  def update
    super
    is_moving = true
    if Gosu::button_down?($keys[:move_forward]) and Gosu::button_down?($keys[:move_left])
      @orientation = :NW
    elsif Gosu::button_down?($keys[:move_forward]) and Gosu::button_down?($keys[:move_right])
      @orientation = :NE
    elsif Gosu::button_down?($keys[:move_backwards]) and Gosu::button_down?($keys[:move_left])
      @orientation = :SW
    elsif Gosu::button_down?($keys[:move_backwards]) and Gosu::button_down?($keys[:move_right])
      @orientation = :SE
    elsif Gosu::button_down?($keys[:move_backwards])
      @orientation = :S
    elsif Gosu::button_down?($keys[:move_forward])
      @orientation = :N
    elsif Gosu::button_down?($keys[:move_left])
      @orientation = :W
    elsif Gosu::button_down?($keys[:move_right])
      @orientation = :E
    else
      is_moving = false
    end

    if !is_moving
      if @frame != 1
          @frame = 1
          update_vertex_array
      end
      @frame_tick = Gosu::milliseconds
    else
      # MOVEMENT
      velocity = 0.8
      case @orientation
      when :N
        @position.x -= velocity * Math::cos(@angles.y * $deg_to_rad)
        @position.z -= velocity * Math::sin(@angles.y * $deg_to_rad)
      when :S
        @position.x += velocity * Math::cos(@angles.y * $deg_to_rad)
        @position.z += velocity * Math::sin(@angles.y * $deg_to_rad)
      when :W
        @position.x -= velocity * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z -= velocity * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      when :E
        @position.x += velocity * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z += velocity * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      when :NW
        @position.x -= velocity * 0.7 * Math::cos(@angles.y * $deg_to_rad)
        @position.z -= velocity * 0.7 * Math::sin(@angles.y * $deg_to_rad)
        @position.x -= velocity * 0.7 * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z -= velocity * 0.7 * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      when :NE
        @position.x -= velocity * 0.7 * Math::cos(@angles.y * $deg_to_rad)
        @position.z -= velocity * 0.7 * Math::sin(@angles.y * $deg_to_rad)
        @position.x += velocity * 0.7 * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z += velocity * 0.7 * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      when :SW
        @position.x += velocity * 0.7 * Math::cos(@angles.y * $deg_to_rad)
        @position.z += velocity * 0.7 * Math::sin(@angles.y * $deg_to_rad)
        @position.x -= velocity * 0.7 * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z -= velocity * 0.7 * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      when :SE
        @position.x += velocity * 0.7 * Math::cos(@angles.y * $deg_to_rad)
        @position.z += velocity * 0.7 * Math::sin(@angles.y * $deg_to_rad)
        @position.x += velocity * 0.7 * Math::cos((@angles.y - 90.0) * $deg_to_rad)
        @position.z += velocity * 0.7 * Math::sin((@angles.y - 90.0) * $deg_to_rad)
      end

      # ANIMATION
      if Gosu::milliseconds - @frame_tick >= @frame_duration
        @frame_tick = Gosu::milliseconds
        case @frame
        when 0
          @frame = 1
          @left_foot = false
        when 1
          @left_foot ? @frame = 0 : @frame = 2
        when 2
          @frame = 1
          @left_foot = true
        end
        # frame was changed, we have to update the Vertex Array values
        update_vertex_array
      end
    end
  end
end
