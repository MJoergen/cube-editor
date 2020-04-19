class Face
   def initialize(window, size, j)
      @window = window
      @image  = Gosu::Image.new('square.png')
      @pixels = 25
      @size   = size
      @max    = size-1
      @id     = j

      clear
   end

   def clear
      @pieces = [6]*(@size*@size)
      if @size % 2 == 1
         @pieces[(@size*@size)/2] = @id
      end
   end

   def full
      @pieces = [@id]*(@size*@size)
   end

   def save(f)
      for y in 0..@max
         s = ""
         for x in 0..@max
            s += "#{@pieces[@size*y+x]}"
         end
         s += "\n"
         f.write(s)
      end
      f.write("\n")
   end

   def load(f, size)
      @size   = size
      @max    = size-1
      @pieces = [6]*(@size*@size)
      for y in 0..@max
         line = f.gets
         for x in 0..@max
            @pieces[@size*y+x] = line[x].to_i
         end
      end
      line = f.gets
   end

   def draw(pos)
      for x in 0..@max
         for y in 0..@max
            @image.draw(pos[:x] + @pixels*x, pos[:y] + @pixels*y, 0, 
                        (@pixels-4.0)/225, (@pixels-4.0)/225,
                        @window.get_col(@pieces[@size*y+x]))
         end
      end
   end

   def draw_line(x1, y1, x2, y2, thickness, col)
      if x1 < x2
         @window.draw_quad(x1+thickness, y1,           col,
                           x1,           y1+thickness, col,
                           x2,           y2-thickness, col,
                           x2-thickness, y2,           col)
      else
         @window.draw_quad(x1-thickness, y1,           col,
                           x1,           y1+thickness, col,
                           x2,           y2-thickness, col,
                           x2+thickness, y2,           col)
      end
   end

   def draw_illegal_face(pos, x, y, c)
      if @pieces[@size*y+x] == c
         draw_illegal(pos, x, y)
      end
      if @pieces[@size*(@max-x)+y] == c
         draw_illegal(pos, y, @max-x)
      end
      if @pieces[@size*(@max-y)+(@max-x)] == c
         draw_illegal(pos, @max-x, @max-y)
      end
      if @pieces[@size*x+(@max-y)] == c
         draw_illegal(pos, @max-y, x)
      end
   end

   def draw_illegal(pos, x, y)
      draw_line(pos[:x] + @pixels*x,         pos[:y] + @pixels*y,
                pos[:x] + @pixels*(x+1) - 4, pos[:y] + @pixels*(y+1) - 4,
                @pixels/4, @window.error_col)
      draw_line(pos[:x] + @pixels*(x+1) - 4, pos[:y] + @pixels*y,
                pos[:x] + @pixels*x,         pos[:y] + @pixels*(y+1) - 4,
                @pixels/4, @window.error_col)
   end

   def get_col(x, y)
      return @pieces[@size*y+x]
   end

   def count_colour(c, x, y)
      r = 0
      if @pieces[@size*y+x] == c
         r += 1
      end
      if @pieces[@size*(@max-x)+y] == c
         r += 1
      end
      if @pieces[@size*(@max-y)+(@max-x)] == c
         r += 1
      end
      if @pieces[@size*x+(@max-y)] == c
         r += 1
      end

      return r
   end

   def mouse(x_rel, y_rel, colour)
      x = (x_rel / @pixels).floor
      y = (y_rel / @pixels).floor
      if @pieces[@size*y+x] < 6
         @pieces[@size*y+x] = 6
      else
         @pieces[@size*y+x] = colour
      end
   end

   def rotate
      for x in 0..(@max/2)
         for y in 0..(@size/2-1)
            tmp = @pieces[@size*y+x]
            @pieces[@size*y+x] = @pieces[@size*(@max-x)+y]
            @pieces[@size*(@max-x)+y] = @pieces[@size*(@max-y)+(@max-x)]
            @pieces[@size*(@max-y)+(@max-x)] = @pieces[@size*x+(@max-y)]
            @pieces[@size*x+(@max-y)] = tmp
         end
      end
   end

end

