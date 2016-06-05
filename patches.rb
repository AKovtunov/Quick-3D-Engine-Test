class Gosu::GLTexInfo
  def tex_coord_2d(x, y)
    tex_x = self.left + x * (self.right - self.left)
    tex_y = (self.bottom + y * (self.top - self.bottom))
    glTexCoord2d(tex_x, tex_y)
  end

  def get_tex_coord_2d(x, y)
    tex_x = self.left + x * (self.right - self.left)
    tex_y = (self.bottom + y * (self.top - self.bottom))
    return [tex_x, tex_y]
  end

  def bottom_left; tex_coord_2d(0.0, 0.0);  end
  def bottom_right; tex_coord_2d(1.0, 0.0);  end
  def top_left; tex_coord_2d(0.0, 1.0);  end
  def top_right; tex_coord_2d(1.0, 1.0);  end
end
