require 'twitter'
require_relative 'bot_brain'

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
    tweet = generate_tweet( bot )
    if tweet
      @client.update( tweet )
      puts tweet
    else
      puts "NO RESULTS"
    end
  end
  
  def test
    bot = @bots.first
    tweet = generate_tweet( bot )
    if tweet
      puts tweet
    else
      puts "NO RESULTS"
    end
  end
    
  def generate_tweet( bot )
    ## Twitter location id
    usa = "23424977"
    ## Get trends
    trends = @client.trends( id=usa )
    ## Find valid trend
    results = []
    valid_trend = nil
    trends.each do |trend|
      ## Ignore promoted content
      next if trend.promoted_content?
      valid_trend = trend
      puts trend.name
      ## Get user timeline
      tweets = @client.user_timeline
      tweets.each do |tweet|
        if tweet.text.downcase.match( trend.name.gsub(' ','').downcase )
          valid_trend = nil
          break
        end
      end
      results = bot.process( valid_trend.name ) if valid_trend
      break if results.any?
    end
    if results.any?
      return results.shuffle.first.tweet.last
    end
    nil
  end
  
  def duplicate?( result )
    search_str = "from:#{@user_screen_name} #{result}"
    results = @client.search( search_str )
    results.any? ? true : false
  end 
  
  def list( name )
    bot = @bots.first
    results = bot.process( name )
    if results.any?
      results.each { |r| puts r.tweet.last }
    else
      puts "NO RESULTS"
    end
  end
  
  private
  
  def setup_bots
    bots = []
    bots << BotBrain.new()
    bots
  end

end