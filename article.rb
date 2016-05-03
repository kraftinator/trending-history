class Article

  attr_accessor :trend
  attr_accessor :trend_words
  attr_accessor :text
  attr_accessor :publication
  attr_accessor :date
  
  def initialize( opts={} )
    @trend = opts[:trend]
    @trend_words = opts[:trend_words]
    @text = opts[:text]
    @publication = opts[:publication]
    @date = opts[:date]
  end
  
  def show
    puts "TREND: #{@trend}"
    puts "PUBLICATION: #{@publication}"
    puts "DATE: #{Date.parse(@date)}"
    puts "--------------------"
    puts @text
    puts "--------------------"
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
    output = "#{Date.parse(@date).strftime("%b %-d, %Y")}: #{output}"
    output
  end
  
end