require_relative 'face.rb'

class Cube
   def initialize(window)
      @window   = window
      @image    = Gosu::Image.new('square.png')
      @font     = Gosu::Font.new(48)
      reset(3)
   end

   def increase
      if @size < 7
         reset(@size+1)
      end
   end

   def decrease
      if @size > 3
         reset(@size-1)
      end
   end

   def reset(size)
      @pixels   = 25
      @size     = size
      @max      = size-1
      @margin   = 10
      @xpos     = 200
      @ypos     = 200

      # Initialize positions on screen of the six faces
      #
      #     1
      #   2 0 3 5
      #     4
      #
      @positions = []
      @positions << {x:@xpos,                               y:@ypos}
      @positions << {x:@xpos,                               y:@ypos - (@size*@pixels + @margin)}
      @positions << {x:@xpos - (@size*@pixels + @margin),   y:@ypos}
      @positions << {x:@xpos + (@size*@pixels + @margin),   y:@ypos}
      @positions << {x:@xpos,                               y:@ypos + (@size*@pixels + @margin)}
      @positions << {x:@xpos + 2*(@size*@pixels + @margin), y:@ypos}

      @faces = []
      for i in 0..5
         @faces << Face.new(@window, @size, i)
      end

      @edges = []
      for i in 0..(@size+1)/2
         @edges << make_edge_list(i)
      end

      # 24 corner pieces (incl rotations)
      @corners = []
      @corners << [0,    0,    0,   1,    0, @max,   2, @max,    0]
      @corners << [0,    0, @max,   2, @max, @max,   4,    0,    0]
      @corners << [0, @max,    0,   3,    0,    0,   1, @max, @max]
      @corners << [0, @max, @max,   4, @max,    0,   3,    0, @max]
      @corners << [1,    0,    0,   5, @max,    0,   2,    0,    0]
      @corners << [1,    0, @max,   2, @max,    0,   0,    0,    0]
      @corners << [1, @max,    0,   3, @max,    0,   5,    0,    0]
      @corners << [1, @max, @max,   0, @max,    0,   3,    0,    0]
      @corners << [2,    0,    0,   1,    0,    0,   5, @max,    0]
      @corners << [2,    0, @max,   5, @max, @max,   4,    0, @max]
      @corners << [2, @max,    0,   0,    0,    0,   1,    0, @max]
      @corners << [2, @max, @max,   4,    0,    0,   0,    0, @max]
      @corners << [3,    0,    0,   1, @max, @max,   0, @max,    0]
      @corners << [3,    0, @max,   0, @max, @max,   4, @max,    0]
      @corners << [3, @max,    0,   5,    0,    0,   1, @max,    0]
      @corners << [3, @max, @max,   4, @max, @max,   5,    0, @max]
      @corners << [4,    0,    0,   0,    0, @max,   2, @max, @max]
      @corners << [4,    0, @max,   2,    0, @max,   5, @max, @max]
      @corners << [4, @max,    0,   3,    0, @max,   0, @max, @max]
      @corners << [4, @max, @max,   5,    0, @max,   3, @max, @max]
      @corners << [5,    0,    0,   1, @max,    0,   3, @max,    0]
      @corners << [5,    0, @max,   3, @max, @max,   4, @max, @max]
      @corners << [5, @max,    0,   2,    0,    0,   1,    0,    0]
      @corners << [5, @max, @max,   4,    0, @max,   2,    0, @max]
   end

   def make_edge_list(i)
      j = @max-i
      edges = []
      edges << [0,    0,    j,   2, @max,    j]
      edges << [0,    i,    0,   1,    i, @max]
      edges << [0,    j, @max,   4,    j,    0]
      edges << [0, @max,    i,   3,    0,    i]
      edges << [1,    0,    j,   2,    j,    0]
      edges << [1,    i,    0,   5,    j,    0]
      edges << [1,    j, @max,   0,    j,    0]
      edges << [1, @max,    i,   3,    j,    0]
      edges << [2,    0,    j,   5, @max,    j]
      edges << [2,    i,    0,   1,    0,    i]
      edges << [2,    j, @max,   4,    0,    i]
      edges << [2, @max,    i,   0,    0,    i]
      edges << [3,    0,    j,   0, @max,    j]
      edges << [3,    i,    0,   1, @max,    j]
      edges << [3,    j, @max,   4, @max,    j]
      edges << [3, @max,    i,   5,    0,    i]
      edges << [4,    0,    j,   2,    i, @max]
      edges << [4,    i,    0,   0,    i, @max]
      edges << [4,    j, @max,   5,    i, @max]
      edges << [4, @max,    i,   3,    i, @max]
      edges << [5,    0,    j,   3, @max,    j]
      edges << [5,    i,    0,   1,    j,    0]
      edges << [5,    j, @max,   4,    i, @max]
      edges << [5, @max,    i,   2,    0,    i]

      return edges
   end

   def clear
      for i in 0..5
         @faces[i].clear
      end
   end

   def full
      for i in 0..5
         @faces[i].full
      end
   end

   def save(filename)
      f = File.open(filename, "w")
      f.write("#{@size}\n")
      for i in 0..5
         @faces[i].save(f)
      end
      f.close()
   end

   def load(filename)
      f = File.open(filename, "r")
      reset(f.gets.to_i)
      for i in 0..5
         @faces[i].load(f, @size)
      end
      f.close()
   end

   def draw
      for i in 0..5
         @faces[i].draw(@positions[i])
      end

      if not legal?
         @font.draw_text("Illegal", 10, 45, 2, 1.0, 1.0,
                         Gosu::Color.argb(0xff_ffffff))
      end
   end

   def check_edges(edges)
      errors = 0
      exp = [0]*36
      obs = [0]*36
      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         exp_colour_pair = 6*edge[3] + edge[0]
         exp[exp_colour_pair] += 1
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            obs[colour_pair] += 1
         end
      end

      for i in 0..23
         edge = edges[i]
         col1 = @faces[edge[0]].get_col(edge[1], edge[2])
         col2 = @faces[edge[3]].get_col(edge[4], edge[5])
         if col1 < 6 and col2 < 6
            colour_pair = 6*col1 + col2
            if obs[colour_pair] > exp[colour_pair]
               @faces[edge[0]].draw_illegal(@positions[edge[0]], edge[1], edge[2])
               @faces[edge[3]].draw_illegal(@positions[edge[3]], edge[4], edge[5])
               errors += 1
            end
         end
      end

      return errors
   end

   def check_corners
      errors = 0
      exp = [0]*216
      obs = [0]*216
      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         exp_colour_pair = 36*corner[0] + 6*corner[3] + corner[6]
         exp[exp_colour_pair] += 1
         if col1 < 6 and col2 < 6 and col3 < 6
            colour_pair = 36*col1 + 6*col2 + col3
            obs[colour_pair] += 1
         end
      end

      for c in 0..23
         corner = @corners[c]
         col1 = @faces[corner[0]].get_col(corner[1], corner[2])
         col2 = @faces[corner[3]].get_col(corner[4], corner[5])
         col3 = @faces[corner[6]].get_col(corner[7], corner[8])
         if col1 < 6 and col2 < 6 and col3 < 6
            colour_pair = 36*col1 + 6*col2 + col3
            if obs[colour_pair] > exp[colour_pair]
               @faces[corner[0]].draw_illegal(@positions[corner[0]], corner[1], corner[2])
               @faces[corner[3]].draw_illegal(@positions[corner[3]], corner[4], corner[5])
               @faces[corner[6]].draw_illegal(@positions[corner[6]], corner[7], corner[8])
               errors += 1
            end
         end
      end

      return errors
   end

   def check_faces
      errors = 0
      for i in 0..2
         for j in 0..3
            for c in 0..5
               count = 0
               for f in 0..5
                  count += @faces[f].count_colour(c, i, j)
               end
               if count > 4
                  for g in 0..5
                     @faces[g].draw_illegal_face(@positions[g], i, j, c)
                  end
                  errors += 1
               end
            end
         end
      end
      return errors
   end

   def legal?
      errors  = check_faces
      for i in 0..(@size+1)/2
         errors += check_edges(@edges[i])
      end
      errors += check_corners

      return (errors == 0)
   end

   def mouse(x, y, colour)
      for i in 0..5
         if x >= @positions[i][:x] and x < @positions[i][:x] + @size*@pixels and
            y >= @positions[i][:y] and y < @positions[i][:y] + @size*@pixels
            @faces[i].mouse(x - @positions[i][:x], y - @positions[i][:y], colour)
         end
      end
   end

   def left
      @faces[1].rotate
      @faces[4].rotate
      @faces[4].rotate
      @faces[4].rotate
      tmp = @faces[5]
      @faces[5] = @faces[2]
      @faces[2] = @faces[0]
      @faces[0] = @faces[3]
      @faces[3] = tmp
   end

   def right
      @faces[1].rotate
      @faces[1].rotate
      @faces[1].rotate
      @faces[4].rotate
      tmp = @faces[5]
      @faces[5] = @faces[3]
      @faces[3] = @faces[0]
      @faces[0] = @faces[2]
      @faces[2] = tmp
   end

   def up
      @faces[5].rotate
      @faces[5].rotate

      @faces[2].rotate
      @faces[2].rotate
      @faces[2].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[1]
      @faces[1] = @faces[0]
      @faces[0] = @faces[4]
      @faces[4] = tmp

      @faces[5].rotate
      @faces[5].rotate
   end

   def down
      @faces[5].rotate
      @faces[5].rotate

      @faces[2].rotate
      @faces[3].rotate
      @faces[3].rotate
      @faces[3].rotate
      tmp = @faces[5]
      @faces[5] = @faces[4]
      @faces[4] = @faces[0]
      @faces[0] = @faces[1]
      @faces[1] = tmp

      @faces[5].rotate
      @faces[5].rotate
   end

end

