require 'gibberish_detector'

class Article

  MAX_CHARS = 140
  MAX_COMMENT_CHARS = 117

  attr_accessor :trend
  attr_accessor :trend_words
  attr_accessor :text
  attr_accessor :publication
  attr_accessor :date
  attr_accessor :url
  
  def initialize( opts={} )
    @trend = opts[:trend]
    @trend_words = opts[:trend_words]
    @text = opts[:text]
    @publication = opts[:publication]
    @date = opts[:date]
    @url = opts[:url]
  end
  
  def show
    puts "TREND: #{@trend}"
    puts "PUBLICATION: #{@publication}"
    puts "DATE: #{Date.parse(@date)}"
    puts "--------------------"
    puts @text
    puts "--------------------"
  end
  
  def can_tweet?
    result, output = tweet
    result
  end
 
  def tweet
    
    output = nil
    sentences = @text.split( ".\n" )
    sentences.each do |sentence|
      if sentence =~ /#{@trend_words}/i
        output = sentence
        break
      end
    end
    
    output.gsub!("\n"," ")
    #output = "#{Date.parse(@date).strftime("%b %-d, %Y")}: #{output}"
    output = "#{Date.parse(@date).strftime("%Y")}: #{output}"
    
    ## Get hashtag
    if @trend[0] == '#'
      hashtag = @trend
    else
      words = @trend_words.split( ' ' )
      words.each { |w| w.capitalize! }
      hashtag = "##{words.join}"
      hashtag.gsub!( "'", "" )
    end

    output.gsub!( /#{@trend_words}/i, hashtag )
    
    ## Reject if hashtag is in all caps
    return false, output if hashtag == hashtag.upcase
    
    if output.size > MAX_COMMENT_CHARS
      output = output[0..MAX_COMMENT_CHARS-2]
      
      output[MAX_COMMENT_CHARS-4] = "."
      output[MAX_COMMENT_CHARS-3] = "."
      output[MAX_COMMENT_CHARS-2] = "."
      
    end
    
    ## Check for search string
    #
    #return false, output unless output =~ /#{hashtag}/i
    #return false, output unless output =~ / #{hashtag} /i
    return false, output unless output =~ / #{hashtag}( |'|\z)/i
     #HermanCain( |')
    return false, output if gibberish?( output ) or false_start?( output )
    
    #url = @url.gsub( "json", "pdf" )
    
    words = @trend_words.split( ' ' )
    search_words = []
    words.each do |word|
      search_words << word
      search_words << word.downcase
      search_words << word.upcase
      search_words << word.capitalize
    end
    search_words.uniq!
    
    #url = @url.gsub( ".json", "/#words=#{@trend_words.gsub( ' ', '+' )}" )
    url = @url.gsub( ".json", "/#words=#{search_words.join('+')}" )
    
    output = "#{output} #{url}"
    
    return true, output
  end
  
  def gibberish?( text )
    
    if text =~ /\s.\s. /i or text =~ /\W{6}/i or text =~ /\w\?\w/i or text =~ /\W\W\w\W\W/i or 
       text =~ /\*|\^|\\/ or text =~ /\W\W\w\w\W\W/i or text =~ /\w#\w/i or text =~ /\:\w/i or !(text =~ / #/i) or
       text =~ /\w,\w/ or
       text =~ / [a-z][A-Z] / or
       text =~ /:!/
      return true
    end

    ############################
    words = text.split(' ')
    #count = 0
    words.each do |word|
      next if word.size < 3
      next if word[0] == '#'
      return true if word =~ /[A-Z]\S*[a-z]\S*[A-Z]/ or word =~ /[a-z]\S*[A-Z]\S*[a-z]/
      
      if word == word.downcase
        if word =~ /[a-z]{3,}/
          return true unless word =~ /a|e|i|o|u|y/
        end
      end
      
      #count += 1 if word.gibberish?
    end
    #return true if count > 1
    ############################

    return false

  end
  
  def false_start?( text )
    sections = text.split( ':')
    s = sections[1][1]
    return false if s == '#'
    if s =~ /\W/i or s =~ /[a-z]|\d/
      return true
    else
      return false
    end
  end
  
end