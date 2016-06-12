require 'rubygems'
require_relative 'bot_controller'

bot_controller = BotController.new

v1 = ARGV[0]

puts v1

bot_controller.list( v1 )