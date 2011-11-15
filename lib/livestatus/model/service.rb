class Livestatus::Service < Livestatus::Base
  def state
    {
      0 => :ok,
      1 => :warning,
      2 => :critical,
      3 => :unknown,
    }[@data[:state]]
  end

  def state_class
    {
      :ok => :green,
      :warning => :orange,
      :critical => :red,
      :unknown => :gray,
    }[state]
  end
end
