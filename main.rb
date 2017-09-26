#!/usr/bin/env ruby

require 'gosu'

require_relative 'cookie'
require_relative 'unit'
require_relative 'cheat'
require_relative 'timer'

def mkUnits(window, list)
  units = []
  list.each_with_index { |u, i|
    units.push(Unit.new(window, 330, 100+i*70, u[0], u[1], u[2], u[3]))
  }
  units
end

class GameWindow < Gosu::Window
  attr_reader :font, :timeHidden, :cookie

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
    @konami = Cheat.new(Gosu::KbUp, Gosu::KbUp, Gosu::KbDown, Gosu::KbDown,
      Gosu::KbLeft, Gosu::KbRight, Gosu::KbLeft, Gosu::KbRight, Gosu::KbB, Gosu::KbA)
    @timeHidden = true
    @goldCookie = GoldenCookie.new(self, 30, 83, "media/goldCookie.png")
    @timers = []
    waitForGoldenCookie(nil)
  end

  def needs_cursor?
    true
  end

  def startTimer(name, delay, meth, arg)
    timer = Timer.new(delay, meth, arg)
    @timers << [name, timer]
  end

  def findTimer(name)
    sel = @timers.select{ |a| a[0] == name }
    if sel.size > 0
      sel[0][1]
    end
  end

  def getTotalCps
    totalCps = 0
    @units.each { |inst|
      totalCps += inst.cps * inst.number
    }
    if findTimer("goldenCookieActive")
      totalCps *= 1.5
    end
    return totalCps
  end

  def waitForGoldenCookie(arg)
    startTimer("waitForGoldenCookie", rand(30*60), self.method(:enableGoldenCookie), nil)
  end
  
  def enableGoldenCookie(arg)
    @goldCookie.enabled = true
  end

  # This event is checked 60 times per second.
  def update
    @timers.reject! { |timer| timer[1].update }

    if findTimer("goldenCookieActive")
      multiplier = 1.5
      self.caption = "Cookie Clicker - [Golden Bonus Timer: " + \
          "#{(findTimer("goldenCookieActive").getvalue/60.0).round(1)}]"
    else
      multiplier = 1
      if findTimer("waitForGoldenCookie")
        self.caption = "Cookie Clicker - Size: #{@timers.size} , " + \
            "Wait: #{(findTimer("waitForGoldenCookie").getvalue/60.0).round(1)}"
      else
        self.caption = "Cookie Clicker - Size: #{@timers.size}"
      end
    end

    @units.each { |inst|
      @cookie.increase(multiplier * inst.cps * inst.number / 60.0)
    }
  end

  # Mouse event
  def mouse(x, y)
    # If the cookie is clicked, you earn one cookie
    if @cookie.in_range?(x, y)
      @cookie.increase(1)
    end

    if @goldCookie.in_range?(x, y)
      @cookie.increase(getTotalCps * 100)
      @goldCookie.enabled = false
      startTimer("goldenCookieActive", rand(30*60), self.method(:waitForGoldenCookie), nil)
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
    @font.draw("Name", x+100, 70, 0)
    @font.draw("Cost", x+200, 70, 0)
    x += 30
    if @timeHidden
      x -= 100
    else
      @font.draw("Time", x+300, 70, 0)
    end
    @font.draw("Amount", x+400, 70, 0)
    @font.draw("Cps", x+500, 70, 0)

    @goldCookie.draw
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
    else
      if @konami.keyPress(id)
        @cookie.increase(8 ** (getTotalCps/10 + 3).to_i)
      end
      # Other cheats should be here
    end
  end
end

GameWindow.new.show
