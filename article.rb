class Article

  attr_accessor :trend
  attr_accessor :text
  attr_accessor :publication
  attr_accessor :date
  
  def initialize( opts={} )
    @trend = opts[:trend]
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
  
end