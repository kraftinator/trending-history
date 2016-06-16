require 'httparty'
require 'active_support'
require 'active_support/core_ext'

require_relative 'article'

class BotBrain

  MAX_CHARS = 140
  
  def initialize( )
  end
  
  def process( trend )
    
    words = extract_words( trend )
    #return false if words.empty?
    return Array.new if words.empty?
    
    items = []
    (1..2).each do |page|
      response = HTTParty.get("http://chroniclingamerica.loc.gov/search/pages/results/?&andtext=&phrasetext=#{words.join('+')}&format=json&page=#{page}")
      break if response['items'].nil? 
      items << response['items']
      items.flatten!
      break if items.size < 20
    end
    #return false if items.empty?
    return Array.new if items.empty?
        
    search_str = words.join(' ')
    results = []
    articles = []
    items.each do |item|
      #next unless item['language'] == "English"
      text = item['ocr_eng']
      next unless text
      phrase = text =~ /#{search_str}/i
      results << text[phrase-100..phrase+100] if phrase
      parsed_phrase = text[phrase-200..phrase+200] if phrase
      next unless parsed_phrase
      next unless parsed_phrase =~ /#{search_str}/i
      article = Article.new( { trend: trend, trend_words: search_str, text: parsed_phrase, publication: item['title'], date: item['date'], url: item['url'] } )
      next unless article.can_tweet?
      articles << article

    end
    
    return articles

  end
  
  def extract_words( name )
     name = I18n.transliterate(name)
     results = []
     ## Handle hashtags
     if name[0] == '#'
       name_without_hash = name.gsub("#", "")
       word_list = name_without_hash.underscore.gsub("_", " ") 
       results = word_list.split
     else
       words = name.split
       results = words
     end
     #####
     results.each { |r| r.downcase! }
     #####
     return results.uniq
   end
  
  def tweet_length( text )
    ActiveSupport::Multibyte::Chars.new(text).normalize(:c).length 
  end
  
  def valid_tweet?( text )
    return false if text.nil?
    tweet_length(text) <= MAX_CHARS ? true : false
  end

end