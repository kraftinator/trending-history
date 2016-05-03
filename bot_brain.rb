require 'httparty'

class BotBrain

  MAX_CHARS = 140
  
  def initialize( )
  end
  
  def process( trend )
    puts trend
    words = extract_words( trend )
    puts words
    return false if words.empty?
    response = HTTParty.get("http://chroniclingamerica.loc.gov/search/pages/results/?&andtext=&phrasetext=#{words.join('+')}&format=json")
    return false if response['items'].nil?  
    items = response['items']
    search_str = words.join(' ')
    results = []
    articles = []
    items.each do |item|
      next unless item['language'] == "English"
      text = item['ocr_eng']
      next unless text
      phrase = text =~ /#{search_str}/i
      results << text[phrase-100..phrase+100] if phrase
      parsed_phrase = text[phrase-200..phrase+200] if phrase
      next unless parsed_phrase
      articles << Article.new( { trend: trend, trend_words: search_str, text: parsed_phrase, publication: item['title'], date: item['date'] } )
    end
    
    return articles
    #if results.any?
    #  return results, true
    #else
    #  return nil, false
    #end
  end
  
  def extract_words( name )
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