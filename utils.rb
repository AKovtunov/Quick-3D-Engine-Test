require 'scanf'

Vector3 = Struct.new(:x, :y, :z)

class GLTexture
	attr_reader :width, :height
	# GOSU IMAGE -> OPENGL TEXTURE FIX
	# SOLVES PROBLEM WITH REPETITION / CROPING
	def initialize(filename, save_gosu_image = false, alpha = true)
		filename.is_a?(Gosu::Image) ? gosu_image = filename : gosu_image = Gosu::Image.new(filename, {:retro=>true, :tileable=>true})
		@width, @height = gosu_image.width, gosu_image.height
		array_of_pixels = gosu_image.to_blob
		@texture_id = glGenTextures(1)
		glBindTexture(GL_TEXTURE_2D, @texture_id[0])
		if alpha
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gosu_image.width, gosu_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		else
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, gosu_image.width, gosu_image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, array_of_pixels)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		end

		if save_gosu_image
			@gosu_image = gosu_image
		else
			gosu_image = nil
		end
	end

	def get_id
		return @texture_id[0]
	end
end

class ObjModel
	def initialize(filename, pivot = [0, 0, 0])
		@v, @vt, @vn = Array.new, Array.new, Array.new
		@pivot = pivot
		v, vt, vn = Array.new, Array.new, Array.new
		File.open(filename).readlines.each do |line|
			if line.include?("v  ")
				ajusted = line.chomp.scanf("v  %f %f %f")
				v << [ajusted[0] - pivot[0], ajusted[1] - pivot[1], ajusted[2] - pivot[2]]
			elsif line.include?("vt  ")
				vt << line.chomp.scanf("vt  %f %f %f")
				vt.last[1] = 1.0 - vt.last[1] # vertical mirror fix
			elsif line.include?("vn  ")
				vn << line.chomp.scanf("vn  %f %f %f")
			elsif line.include?("f ")
				t = line.chomp.scanf("f %d/%d/%d %d/%d/%d %d/%d/%d")
				@v += v[t[0] - 1]; @v += v[t[3] - 1]; @v += v[t[6] - 1]
				@vt += vt[t[1] - 1]; @vt += vt[t[4] - 1]; @vt += vt[t[7] - 1]
				@vn += vn[t[2] - 1]; @vn += vn[t[5] - 1]; @vn += vn[t[8] - 1]
			end
		end
	end

	def draw(texture, position = [0, 0, 0])
		glBindTexture(GL_TEXTURE_2D, texture.get_id)
		glPushMatrix
		glTranslate(position[0], position[1], position[2])
		glVertexPointer(3, GL_FLOAT, 0, @v)
		glTexCoordPointer(3, GL_FLOAT, 0, @vt)
		glNormalPointer(GL_FLOAT, 0, @vn)
		glDrawArrays(GL_TRIANGLES, 0, @v.size / 3)
		glPopMatrix
	end
end

# global variables setup
$keys = {
  :move_forward => Gosu::KbW,
  :move_backwards => Gosu::KbS,
  :move_left => Gosu::KbA,
  :move_right => Gosu::KbD
}

class Float
  def to_rad
    self * Math::PI / 180.0
  end
end
