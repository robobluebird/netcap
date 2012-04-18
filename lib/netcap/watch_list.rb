require './netcap/watched'
class WatchList
  def list
    @list ||= []
  end

  def add_from_params(address, make)
    list << Watched.new(address, {"manufacturer" => make})
  end

  def add(watched)
    list << watched
  end

  def add_token_by_address(address, token)
    list.each do |w|
      if w.address == address
        unless w.has_token? token
          w.add_token(token)
        end
      end
    end
  end

  def scan_for_events(watchlist)
    list.each do |watched|
      if events_to_check = @events[watched.type.to_sym]
        events_to_check.each do |event|
          if separation_sorted?(event.tokens, watched.tokens)
            #do something with event and watched item
            puts "sending event"
          end
        end
      end
    end
  end

  def separation_sorted?(event_tokens, device_tokens)
    device_tokens.inject(0) do |acc, item|
      break acc if acc == event_tokens.length
      event_tokens[acc] == item ? acc += 1 : acc
    end == event_tokens.length
  end

  def watching?(addy)
    list.any? {|item| item.address == addy}
  end

  def update
    list.map {|item| yield(item)}
  end
end
