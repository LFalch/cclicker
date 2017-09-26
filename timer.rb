class Timer
  def initialize(delay, callback=nil, arg=nil)
    @delay = delay
    @callback = callback
    @arg = arg
  end

  def update
    if (@delay > 0) then
      @delay -= 1
      return false
    end

    if @callback
      @callback.call(@arg)
    end
    return true
  end

  def getvalue
    return @delay
  end
end
