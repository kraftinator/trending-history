require 'twitter'

class BotController
  
  def initialize
    ## Bot user
    @user_screen_name = "TrendingHx"
    ## App config settings
    config = {
      consumer_key:        ENV['TRENDING_HISTORY_CONSUMER_KEY'],
      consumer_secret:     ENV['TRENDING_HISTORY_CONSUMER_SECRET'],
      access_token:        ENV['TRENDING_HISTORY_ACCESS_TOKEN'],
      access_token_secret: ENV['TRENDING_HISTORY_ACCESS_TOKEN_SECRET']
    }

    
    ## Get client
    @client = Twitter::REST::Client.new( config )
    ## Setup bots
    @bots = setup_bots
  end
  
  def tweet
    
    bot = @bots.first

    ## Twitter location id
    usa = "23424977"
    
    trends = @client.trends( id=usa )
    current_trend = nil
    trends.each do |trend|
      next if trend.promoted_content?
      current_trend = trend
      current_trend.name
      break if current_trend
    end
    
=begin    
    5.times do
      success, result = bot.build_text
      if success
        next if duplicate?( result )
        @client.update( result )
        puts result
        break
      else
        puts "ERROR: #{result}"
      end
    end
    true
=end
  end
  
  def duplicate?( result )
    search_str = "from:#{@user_screen_name} #{result}"
    results = @client.search( search_str )
    results.any? ? true : false
  end 
  
  def list
    bot = @bots.first
    success, result = bot.build_text
    if success
      puts result
    else
      puts "ERROR: #{result}"
    end
  end
  
  private
  
  def setup_bots
    bots = []
    bots << BotBrain.new(@client)
    bots
  end

end