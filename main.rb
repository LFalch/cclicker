#!/usr/bin/env ruby

require 'gosu'

require_relative 'cookie.rb'
require_relative 'unit.rb'

def mkUnits(window, list)
  units = []
  list.each_with_index { |u, i|
    units.push(Unit.new(window, 330, 50+i*70, u[0], u[1], u[2], u[3]))
  }
  units
end


class GameWindow < Gosu::Window
  attr_reader :font, :timeHidden, :cookie

  Konami = [Gosu::KbUp, Gosu::KbUp, Gosu::KbDown, Gosu::KbDown, Gosu::KbLeft,
    Gosu::KbRight, Gosu::KbLeft, Gosu::KbRight, Gosu::KbB, Gosu::KbA]

  def initialize
    super(940, 600, false)  # Set size of window
    self.caption = "Cookie Clicker"
    @font   = Gosu::Font.new(self, Gosu.default_font_name, 24)

    @cookie = Cookie.new(self, 100, 100, "media/PerfectCookie.png")

    @units = mkUnits(self, [
      ["CursorIconTransparent", "Cursor",     15.0,    0.1],
      ["grandma",               "Grandma",   100.0,      1],
      ["FarmIconTransparent",   "Farm",      1.1e3,      8],
      ["mine",                  "Mine",      1.2e4,     47],
      ["factory",               "Factory",   1.3e5,    260],
      ["bank",                  "Bank",      1.4e6,  1.4e3],
    ])
    @konamiProgress = 0
    @timeHidden = true
  end

  def needs_cursor?
    true
  end

  def getTotalCps
    totalCps = 0
    @units.each { |inst|
      totalCps += inst.cps * inst.number
    }
    return totalCps
  end

  # This event is checked 60 times per second.
  def update
    @units.each { |inst|
      @cookie.increase(inst.cps * inst.number / 60.0)
    }
  end

  # Mouse event
  def mouse(x, y)
    # If the cookie is clicked, you earn one cookie
    if @cookie.in_range?(x, y)
      @cookie.increase(1)
    end

    # If a unit is clicked, we try to buy it
    @units.each { |inst|
      if inst.in_range?(x, y)
        # Buy if afffordable
        if @cookie.cookies >= inst.cost
          @cookie.increase(-inst.cost)
          inst.buy
        end
      end
    }
  end

  def draw
    @font.draw("Cookies: #{@cookie.cookies.to_i}", 20, 20, 0)
    @font.draw("CPS: #{getTotalCps.round(1)}", 20, 300, 0)

    x = 330
    @font.draw("Name", x+100, 20, 0)
    @font.draw("Cost", x+200, 20, 0)
    x += 30
    if @timeHidden
      x -= 100
    else
      @font.draw("Time", x+300, 20, 0)
    end
    @font.draw("Amount", x+400, 20, 0)
    @font.draw("Cps", x+500, 20, 0)
    @cookie.draw
    @units.each { |inst|  inst.draw }
  end

  def button_down(id)
    if id == Gosu::KbT
      @timeHidden = !@timeHidden
    end

    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      mouse(mouse_x, mouse_y)   # We have clicked the mouse!
    elsif id == Konami[@konamiProgress]
      @konamiProgress += 1
      if @konamiProgress == Konami.length
        @cookie.increase(10 ** (getTotalCps/10 + 4).to_i)
        @konamiProgress = 0
      end
    else
      @konamiProgress = 0
    end
  end
end

GameWindow.new.show
