# This class holds information for each type of unit
# This includes:
# number : Number of units owned
# cost   : The price of the next unit
# cps  : Cookies pr. second for each unit

def humanise(num)
  num.to_s.gsub(/(?<=\d)(?=(?:\d{3})+\z)/, ' ')
end

class Unit
  attr_reader :number
  attr_accessor :cps

  def initialize(window, x, y, img, name, cost, cps)
    @window, @x, @y, @name, @cost, @cps = window, x, y, name, cost, cps

    @image  = Gosu::Image.new("media/#{img}.png")
    @scale  = 50.0 / @image.height      # Make sure all images on screen
                        # have the same height (50 pixels).
    @number = 0
  end

  def buy
    @number += 1
    @cost *= 1.15
  end

  # When buying units, the price is always rounded up.
  def cost
    @cost.ceil
  end

  # Check if (x,y) is within the image of the unit
  def in_range?(x, y)
    (x >= @x and x < @x + @image.width*@scale and
     y >= @y and y < @y + @image.height*@scale)
  end

  def draw
    colour = 0xff_ffffff
    if @window.cookie.cookies < @cost
      colour = 0xff_626262
    end
    # "Zoom in" when mouse is pressed
    if Gosu::button_down?(Gosu::MsLeft) and in_range?(@window.mouse_x, @window.mouse_y)
      @image.draw(@x-2, @y-2, 0, @scale*1.08, @scale*1.08, colour)
    else
      @image.draw(@x, @y, 0, @scale, @scale, colour)
    end
    @window.font.draw(@name,         @x+100, @y+20, 0)
    @window.font.draw("#{humanise(cost)}",       @x+200, @y+20, 0)
    x = @x + 30
    if @window.timeHidden
      x -= 100
    else
      @window.font.draw("#{humanise((cost/@cps).ceil)}", x+300, @y+20, 0)
    end
    @window.font.draw("#{humanise(number)}", x+400, @y+20, 0)
    @window.font.draw("#{humanise(cps)}", x+500, @y+20, 0)
  end
end
