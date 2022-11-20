require 'rubygems'
require 'gosu'

module ZOrder
	BACKGROUND, MIDDLE, TOP = *0..2
end
  
# Global constants
WIN_WIDTH = 640
WIN_HEIGHT = 400

class ArtWork
	attr_accessor :bmp
	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end