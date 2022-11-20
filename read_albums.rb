require 'rubygems'
require './album_init'

def read_albums(music_file)
	albums = []
	album_count = music_file.gets().to_i()
	for i in 0..album_count-1
	  	album = read_album(music_file)
	  	albums << album
	end
	return albums
end

def read_album(music_file)
    album_artist = music_file.gets()
    album_title = music_file.gets()
	album_year = music_file.gets()
	album_genre = music_file.gets()
	album_artwork = music_file.gets()
    tracks = read_tracks(music_file)
    album = Album.new(album_artist, album_title, album_year, album_genre, album_artwork, tracks)
	return album
end

def read_tracks(music_file)
	count = music_file.gets().to_i()
	tracks = ['Null']
	if count > 0
		for i in 0..count-1
			track = read_track(music_file)
			tracks << track
		end
	end
	return tracks
end

def read_track(a_file)
	name = a_file.gets()
	location = a_file.gets()
	seconds = a_file.gets()
	view = 0
	track = Track.new(name,location,view,seconds)
	return track
end

def read_albums_tracks(filename)
    music_file = File.new(filename, "r")
	albums = read_albums(music_file)
	music_file.close()
	return albums
end