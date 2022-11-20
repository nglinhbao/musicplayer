require 'rubygems'

module Genre
	POP, CLASSIC, JAZZ, ROCK = *1..4
end

class Track
	attr_accessor :name, :location, :view, :seconds
	def initialize (name, location, view, seconds)
		@name = name
		@location = location
		@view = view
		@seconds = seconds
	end
end

class Playlist_Track
	attr_accessor :name, :location, :org_album_number, :org_track_number, :seconds
	def initialize (name, location, org_album_number, org_track_number, seconds)
		@name = name
		@location = location
		@org_album_number = org_album_number
		@org_track_number = org_track_number
		@seconds = seconds
	end
end
  
class Album
	attr_accessor :artist, :title, :year, :genre, :artwork, :tracks
	def initialize (artist, title, year, genre, artwork, tracks)
		@artist = artist
		@title = title
		@year = year
		@genre = genre
		@artwork = artwork
        @tracks = tracks
	end
end

class Array
    def shuffle
        sort_by { rand }
    end
end