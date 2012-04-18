class Event
  # @events ||= {:Microsoft => [{:event_num => 1, :token_string => [1,2,3]}]}
  def type
    @type ||= "General"
  end

  def event_id
    @event_id ||= 0
  end

  def tokens
    @tokens ||= []
  end

  def initialize(type="General", event_id=0, tokens=[])
    @type = type
    @event_id = event_id
    @tokens = tokens
  end
end
