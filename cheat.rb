class Cheat
  def initialize(*keys)
    @keys = keys
    @progress = 0
  end

  # Returns true if cheat has been finished
  def keyPress(key)
    if key == @keys[@progress]
      @progress += 1

      if @progress == @keys.length
        @progress = 0
        return true
      end
    else
      @progress = 0
    end
    return false
  end
end
