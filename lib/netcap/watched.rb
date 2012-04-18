class Watched
  def type
    @type ||= ""
  end

  def type=(str)
    @type = str
  end

  def address
    @address ||= ""
  end

  def address=(str)
    @address = str
  end

  def manufacturer
    @manufacturer ||= ""
  end

  def manufacturer=(manu)
    @manufacturer = manu
  end

  def options
    @options ||= {}
  end

  def sites
    @sites ||= []
  end

  def agent
    @agent ||= ""
  end

  def agent=(str)
    @agent = str
  end

  def tokens
    @tokens ||= []
  end

  def searches
    @searches ||= []
  end

  def youtubes
    @youtubes ||= []
  end

  def counts
    @counts ||= {}
  end

  def posts
    @posts ||= []
  end

  def initialize(address="", manufacturer="", sites=[], agent="",
                 tokens=[], searches=[], youtubes=[], counts={}, posts=[])
    @address = address
    @manufacturer = manufacturer
    @sites = sites
    @agent = agent
    @tokens = tokens
    @searches = searches
    @youtubes = youtubes
    @counts = counts
    @posts = posts
  end

  def has_token?(token)
    tokens.include? token
  end

  def add_token(token)
    tokens << token
  end

  def print
    puts "**********************************************"
    puts "\nagent --------------\n" + self.agent + "\n\n" + "\naddress ------------\n" + self.address + "\n"
    puts "\nsites --------------"
    @sites.each do |s|
      puts s + " - " + @counts[s].to_s
    end
    puts "\nsearches -----------"
    @searches.each do |se|
      puts se
    end
    puts "\nyoutubes -----------"
    @youtubes.each do |y|
      puts y
    end
    puts "\nPOST req's -----------"
    @posts.each do |y|
      puts y
    end
    puts "\n"
  end
end
