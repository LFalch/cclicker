class Upgrade
  def initialize(window, img, name, cost, reward)
    @window, @name, @cost, @reward = window, name, cost, reward
    @img = Gosu::Image.new("media/#{img}.png")
  end

  def draw(x=10, y=20)
    @img.draw(x, y, 0)
  end

  def apply(win)
    reward.call(win)
  end

  def in_range?(x, y)
    false
  end
end
