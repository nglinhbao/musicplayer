#cd Library/CloudStorage/OneDrive-SwinburneUniversity/COS10009/portfolio/tmp

require './input_functions'
require 'rubygems'
require 'gosu'

#--------------------------------Album init---------------------------------------

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

#--------------------------------Read Album---------------------------------------

dir = './albums' # desired directory
files = Dir.glob(File.join(dir, '**', '*')).select{|file| File.file?(file)}

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

#--------------------------------GUI init---------------------------------------

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

#--------------------------------DRAW AND MUSIC---------------------------------------

class MusicPlayerMain < Gosu::Window
	attr_accessor :bmp
	def initialize(files)

		@albums = ['Null']
		files.each do |f|
			albums_res = read_albums_tracks(f)
			for i in albums_res
				@albums << i
			end
		end
        @albums2 = @albums

		super(WIN_WIDTH, WIN_HEIGHT, false)
		@background = Gosu::Color::WHITE
		@tracks_font = Gosu::Font.new(10)
		@info_font = Gosu::Font.new(10)
		@sort_font = Gosu::Font.new(20)
		@menu = Gosu::Font.new(10)
		@locs = [60,60]
		@play_button = ArtWork.new("images/play_button.bmp")
		@next_button_left = ArtWork.new("images/next_button_left.bmp")
		@next_button_right = ArtWork.new("images/next_button_right.bmp")
		@next_button_up = ArtWork.new("images/next_button_up.bmp")
		@next_button_down = ArtWork.new("images/next_button_down.bmp")
		@song_selected_arrow = ArtWork.new("images/song_selected.bmp")
		@shuffle_button = ArtWork.new("images/shuffle.bmp")
		@volume_up_button = ArtWork.new("images/volume_up.bmp")
		@volume_down_button = ArtWork.new("images/volume_down.bmp")
		@replay_button = ArtWork.new("images/replay_button.bmp")
		@white_bar = ArtWork.new("images/white_bar.bmp")
		@logo = ArtWork.new("images/logo.bmp")
		@sort_choice = 0
		@start = false
		@playlist = ['Null']
		@playlists = ['Null']
		@playlist_loc = Array.new()
		@playlist_number = 1
		@queue = ['Null', 1]
		@shuffle_clicked = false
		@add_queue = []
		@queue_index = 1
		@replay = false
		@replay_time = 0
		@playlist_playing = false
		@playlist_album_number = []
		@playlist_track_number = []
		@show_ranking = false
		@start_time = 0
		@percent = 0
		@width = 0
		@length = 240
		@current_time = 0
		@checkpoint_add_start_time = 0
	end

	def sorting_year(albums)
		order = []
		years_arr = Array.new()
		for i in 1..albums.length()-1
			years_arr << albums[i].year.chomp.to_i
		end
		years_arr = years_arr.sort
		for j in 0..years_arr.length()-1
			for k in 1..albums.length()-1
				if years_arr[j].to_i == albums[k].year.chomp.to_i
					order << k
					break
				end
			end
		end
		return order
	end

	def sorting_genre(albums)
		order = []
		for i in 1..4
			for k in 1..albums.length()-1
				if i == albums[k].genre.chomp.to_i
					order << k
					break
				end
			end
		end
		return order
	end

	def sorting_number_tracks(albums)
		order = []
		tracks_number_array = []
		for i in 1..albums.length()-1
			if order.length == 0
				order << i
			else
				for j in 0..order.length-1
					if albums[order[j]].tracks.length > albums[i].tracks.length
						puts 'a'
						order.insert(j, i)
						break
					end
					if j == order.length-1
						order << i
					end
				end
			end
		end
		puts order
		return order
	end

    def no_sort(albums)
        order = []
        for i in 1..albums.length-1
            order << i
        end
		return order
    end

	def sorting_main(albums, sort_choice)
		if sort_choice == 1
            return no_sort(albums)
		elsif sort_choice == 2
			return sorting_year(albums)
		elsif sort_choice == 3
			return sorting_genre(albums)
		elsif sort_choice == 4
			return sorting_number_tracks(albums)
		end
	end

	def draw_sort_info()
		@sort_font.draw('All albums', 250, 60, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@sort_font.draw('Sort by year', 250, 100, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@sort_font.draw('Sort by genre', 250, 140, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@sort_font.draw('Sort by number of tracks', 250, 180, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@sort_font.draw('Show playlists', 250, 220, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@sort_font.draw('Show most viewed songs', 250, 260, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK) 
		@logo.bmp.draw(20,100,0)
	end

	def pages_cal(len)
		remain = 0
		while len % 4 != 0
			len -= 1
			remain += 1
		end
		if remain == 0
			return len/4
		else
			return len/4+1
		end
	end

	def playTrack()
		# complete the missing code
		if @playlist_playing
			album_number = @albums[@album_number].tracks[@queue[@song_playing_index]].org_album_number
			track_number = @albums[@album_number].tracks[@queue[@song_playing_index]].org_track_number
			@albums2[album_number].tracks[track_number].view += 1
		else
			@albums[@album_number].tracks[@queue[@song_playing_index]].view += 1
		end

		for i in 1..@albums[@album_number].tracks.length-1
			if !@playlist_playing
				puts @albums[@album_number].tracks[i].name
				puts @albums[@album_number].tracks[i].view
			end
		end

		@start_time = Gosu.milliseconds
		@song = Gosu::Song.new(@albums[@album_number].tracks[@queue[@song_playing_index]].location.chomp)
		@song.play(false)
	end

	def draw_album(album_number)
		if @album_clicked == false
			if mouse_over_album(mouse_x, mouse_y)
				Gosu.draw_rect(260, 15, 320, 370, Gosu::Color::CYAN, ZOrder::BACKGROUND, mode=:default)
			end
		end
		@album_artwork = ArtWork.new(@albums[album_number].artwork.chomp)
		@album_artwork.bmp.draw(270, 25, 0)
		@menu.draw('Menu', 15, 320, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
	end

	def draw_tracks_name(album_number)
		y_index = 65
		for i in @small_track..@big_track
			@tracks_font.draw(@albums[album_number].tracks[i].name.chomp, 25, y_index, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
			y_index += 40
		end
	end

	def draw_album_info(album_number)
		@tracks_font.draw("Title: " + @albums[album_number].title, 270, 340, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
		@tracks_font.draw("Artist: " + @albums[album_number].artist, 270, 360, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
		@tracks_font.draw("Year: " + @albums[album_number].year.to_s, 480, 340, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
		genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']
		@tracks_font.draw("Genre: " + genre_names[@albums[album_number].genre.to_i].to_s.chomp, 480, 360, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
	end

	def draw_ranking
		y = 20
		for i in 0..@ranking_name.length-1
			s = @ranking_name[i].to_s.chomp + ': ' + @view_time[i].to_s
			@tracks_font.draw(s, 270, y, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
			y += 40
		end
		@logo.bmp.draw(20,100,0)
		@menu.draw('Menu', 15, 320, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
	end

	def highlight(song_playing)
		track_y_index = 0
		for i in 1..song_playing - (@page-1)*4
			if i == 1
				track_y_index += 65
			else
				track_y_index += 40
			end
		end
		if song_playing <= @page*4 and song_playing > (@page-1)*4
			@play_button.bmp.draw(-23, track_y_index-18, 0)
		end
	end

	def song_selected_highlight(playlist)
		for k in 1..playlist.length()-1
			for j in @small_track..@big_track
				if playlist[k].name.chomp == @albums[@album_number].tracks[j].name.chomp
					track_y_index = 0
					for i in 1.. j - (@page-1)*4
						if i == 1
							track_y_index += 83
						else
							track_y_index += 40
						end
					end
					@song_selected_arrow.bmp.draw(175, track_y_index-18, 0)
				end
			end
		end
	end

	def draw_bar
		if !@song.paused?
			@length = @albums[@album_number].tracks[@queue[@song_playing_index]].seconds.to_i*1000
			@current_time = (Gosu.milliseconds - @start_time).to_f
		end
		@percent = (@current_time/@length).to_f
		@width = (170*@percent).to_i
		Gosu.draw_rect(15, 255, 170, 5, Gosu::Color::GRAY, ZOrder::MIDDLE, mode=:default)
		Gosu.draw_rect(15, 255, @width, 5, Gosu::Color::CYAN, ZOrder::TOP, mode=:default)
	end

	def draw_background()
		Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
		Gosu.draw_rect(0, 0, 200, WIN_HEIGHT, Gosu::Color::YELLOW, ZOrder::BACKGROUND, mode=:default)
		if @start
			@next_button_left.bmp.draw(190, 170, 0)
			@next_button_right.bmp.draw(590, 170, 0)
		end
		if @album_clicked
			@next_button_up.bmp.draw(87, 25, 0)
			@next_button_down.bmp.draw(87, 210, 0)
		end
	end

	def next_song(album_number)
		if @replay
			if @album_clicked
				if @song.paused? == false
					if @song.playing? == false
						playTrack
					end
				end
			end
		else
			if @album_clicked
				if @song_playing_index != @queue.length()-1
					if @song.paused? == false
						if @song.playing? == false
							@song_playing_index += 1
							@queue_index = 1
							playTrack
						end
					end
				end
			end
		end
	end

	def draw()
		# Draw background color
		draw_background

		if @start == false
			if @show_ranking
				draw_ranking
			else
				draw_sort_info()
				@playlist.clear()
				@playlist_loc.clear()
				@playlist << 'Null'
				@playlist_loc << 'Null'
			end
		else
			next_song(@album_number)
			draw_album(@album_number)

			if @playlist.length > 1
				if @album_clicked
					song_selected_highlight(@playlist)
				end
				@menu.draw("Create", 70, 310, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
				@menu.draw("playlist", 70, 330, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)

				@menu.draw("Add to", 135, 310, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
				@menu.draw("queue", 135, 330, ZOrder::TOP, 1.5, 1.5, Gosu::Color::BLACK)
			end

			if @album_clicked
				draw_bar
				@shuffle_button.bmp.draw(15, 273, 0)
				@volume_down_button.bmp.draw(60, 270, 0) #shuffle -15 #-25
				@volume_up_button.bmp.draw(105, 270, 0)
				@replay_button.bmp.draw(150, 270, 0)
				Gosu.draw_rect(260, 15, 320, 370, Gosu::Color::CYAN, ZOrder::BACKGROUND, mode=:default)
				draw_tracks_name(@album_number)
				@album_artwork.bmp.draw(270, 25, 0)
				draw_album_info(@album_number)
			end

			if @album_clicked
				highlight(@queue[@song_playing_index])
			end
		end

		# Draw the mouse_x position
		@info_font.draw("mouse_x: #{mouse_x}", 0, 370, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		# Draw the mouse_y position
		@info_font.draw("mouse_y: #{mouse_y}", 100, 370, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
	end

	# this is called by Gosu to see if it should show the cursor (or mouse)
	def needs_cursor?; true; end

#--------------------------------Mouse over---------------------------------------

	def mouse_over_album(mouse_x, mouse_y)
		if ((mouse_x > 270 and mouse_x < 570) and (mouse_y > 25 and mouse_y < 325))
			true
		else
			false
		end
	end

	def mouse_over_left_button(mouse_x, mouse_y)
		if ((mouse_x > 200 and mouse_x < 260) and (mouse_y > 165 and mouse_y < 225))
			true
		else
			false
		end
	end

	def mouse_over_right_button(mouse_x, mouse_y)
		if ((mouse_x > 580 and mouse_x < 640) and (mouse_y > 165 and mouse_y < 225))
			true
		else
			false
		end
	end

	def mouse_over_up_button(mouse_x, mouse_y)
		if ((mouse_x > 84 and mouse_x < 113) and (mouse_y > 34 and mouse_y < 55))
			true
		else
			false
		end
	end

	def mouse_over_down_button(mouse_x, mouse_y)
		if ((mouse_x > 84 and mouse_x < 113) and (mouse_y > 202 and mouse_y < 225))
			true
		else
			false
		end
	end

	def mouse_over_sort_all(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 55 and mouse_y < 95))
			true
		else
			false
		end
	end

	def mouse_over_sort_year(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 95 and mouse_y < 135))
			true
		else
			false
		end
	end

	def mouse_over_sort_genre(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 135 and mouse_y < 175))
			true
		else
			false
		end
	end

	def mouse_over_sort_number_tracks(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 175 and mouse_y < 215))
			true
		else
			false
		end
	end

	def mouse_over_playlists(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 215 and mouse_y < 245))
			true
		else
			false
		end
	end

	def mouse_over_ranking(mouse_x, mouse_y)
		if ((mouse_x > 240 and mouse_x < 560) and (mouse_y > 255 and mouse_y < 285))
			true
		else
			false
		end
	end

	def mouse_over_menu(mouse_x, mouse_y)
		if ((mouse_x > 10 and mouse_x < 50) and (mouse_y > 315 and mouse_y < 335))
			true
		else
			false
		end
	end

	def mouse_over_finish(mouse_x, mouse_y)
		if ((mouse_x > 65 and mouse_x < 110) and (mouse_y > 305 and mouse_y < 345))
			true
		else
			false
		end
	end

	def mouse_over_queue(mouse_x, mouse_y)
		if ((mouse_x > 135 and mouse_x < 175) and (mouse_y > 305 and mouse_y < 345))
			true
		else
			false
		end
	end

	def mouse_over_pause(mouse_x, mouse_y, track_number)
		y = 0
		#60 85
		for i in 1..track_number
			if i == 1
				y += 60
			else
				y += 40
			end
		end
		if ((mouse_x > 0 and mouse_x < 25) and (mouse_y > y and mouse_y < y + 25))
			true
		else
			false
		end
	end

	def mouse_over_shuffle(mouse_x, mouse_y)
		if ((mouse_x > 15 and mouse_x < 45) and (mouse_y > 270 and mouse_y < 300))
			true
		else
			false
		end
	end

	def mouse_over_volumn_down(mouse_x, mouse_y)
		if ((mouse_x > 65 and mouse_x < 88) and (mouse_y > 270 and mouse_y < 300))
			true
		else
			false
		end
	end

	def mouse_over_volumn_up(mouse_x, mouse_y)
		if ((mouse_x > 105 and mouse_x < 137) and (mouse_y > 270 and mouse_y < 300))
			true
		else
			false
		end
	end

	def mouse_over_replay(mouse_x, mouse_y)
		if ((mouse_x > 150 and mouse_x < 182) and (mouse_y > 270 and mouse_y < 300))
			true
		else
			false
		end
	end

	def mouse_over_track(mouse_x, mouse_y, track_number)
		y = 0
		for i in 1..track_number
			if i == 1
				y += 50
			else
				y += 40
			end
		end

		if ((mouse_x > 25 and mouse_x < 200) and (mouse_y > y and mouse_y < y + 40))
			true
		else
			false
		end
	end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.

#--------------------------------BUTTON---------------------------------------

	def button_down(id)
		check_mouse_over_track = false
		case id
		when Gosu::MsLeft
			if @start
				for i in 1..4
					if mouse_over_track(mouse_x, mouse_y, i)
						if @album_clicked
							if i + 4*(@page-1) < @albums[@album_number].tracks.length
								@song_playing_index = i + 4*(@page-1)
								check_mouse_over_track = true
								@queue = ['Null']
								for i in 1..@albums[@album_number].tracks.length - 1
									@queue << i
								end
								@shuffle_clicked = false
								@queue_index = 1
								playTrack
								puts @queue
								puts 'mouse over track'
							end
						end
					end
				end

				if mouse_over_album(mouse_x, mouse_y)
					@song_playing_index = 1
					@queue_index = 1
					@queue = ['Null']
					for i in 1..@albums[@album_number].tracks.length - 1
						@queue << i
					end
					@shuffle_clicked = false
					playTrack()
					@album_clicked = true
					@small_track = 1
					if @albums[@album_number].tracks.length - 1 >= 4
						@big_track = 4
					else
						@big_track = @albums[@album_number].tracks.length - 1
					end 
					puts @queue
					puts 'mouse over album'
				elsif mouse_over_pause(mouse_x, mouse_y, @queue[@song_playing_index] - 4*(@page-1))
					if @album_clicked
						if @song.paused? 
							@song.play
							@start_time += Gosu.milliseconds - @checkpoint_add_start_time
						else
							@song.pause
							@checkpoint_add_start_time = Gosu.milliseconds
						end
					end
				elsif mouse_over_left_button(mouse_x, mouse_y)
					if @album_number_index != 0
						@album_number_index -= 1
                        @album_number = @order[@album_number_index]
						@album_clicked = false
						@song_playing_index = 1
						@small_track = 1
						@shuffle_clicked = false
						if @albums[@album_number].tracks.length - 1 >= 4
							@big_track = 4
						else
							@big_track = @albums[@album_number].tracks.length - 1
						end 
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@page = 1
						@queue = ['Null']
						for i in 1..@albums[@album_number].tracks.length - 1
							@queue << i
						end
						if @album_clicked == false
							@song = Gosu::Song.new(@albums[@album_number].tracks[@queue[@song_playing_index]].location.chomp)
							@song.stop
						end
					end
				elsif mouse_over_right_button(mouse_x, mouse_y)
					if @album_number_index != @order.length()-1
						@album_number_index += 1
					    @album_number = @order[@album_number_index]
						@album_clicked = false
						@song_playing_index = 1
						@small_track = 1
						@shuffle_clicked = false
						if @albums[@album_number].tracks.length - 1 >= 4
							@big_track = 4
						else
							@big_track = @albums[@album_number].tracks.length - 1
						end
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@page = 1
						@queue = ['Null']
						for i in 1..@albums[@album_number].tracks.length - 1
							@queue << i
						end
						if @album_clicked == false
							@song = Gosu::Song.new(@albums[@album_number].tracks[@queue[@song_playing_index]].location.chomp)
							@song.stop
						end
					end
				elsif mouse_over_up_button(mouse_x, mouse_y)
					if @album_clicked
						if @page != 1
							@page -= 1
							@small_track -= 4
							@big_track = @small_track + 3
						end
					end
				elsif mouse_over_down_button(mouse_x, mouse_y)
					if @album_clicked
						if @page != @pages
							@page += 1
							@small_track += 4
							if @big_track + 4 > @albums[@album_number].tracks.length - 1
								@big_track = @albums[@album_number].tracks.length - 1
							else
								@big_track += 4
							end
						end
					end
				elsif mouse_over_menu(mouse_x, mouse_y)
					@show_ranking = false
					@start = false
					@album_clicked = false
					if @playlist_playing
						@albums = @albums2
						@playlist_playing = false
					end
					if @song.playing?
						@song.stop
					end
				elsif mouse_over_shuffle(mouse_x, mouse_y)
					if @album_clicked
						@queue.delete('Null')
						@queue = @queue.shuffle
						@queue.unshift('Null')
						@shuffle_clicked = true
						@song_playing_index = 1
						playTrack
						puts @queue
						puts 'mouse over shuffle'
					end
				elsif mouse_over_finish(mouse_x, mouse_y)
					if @playlist.length > 1
						res_playlist = Array.new()
						for i in @playlist
							res_playlist << i
						end
						res_album = Album.new('User', 'Playlist '+ @playlist_number.to_s, 2022, 0, 'images/playlist.bmp', res_playlist)
						@playlist_number += 1
						@playlists << res_album
						@playlist.clear
						@playlist_loc.clear
						@playlist << 'Null'
						@playlist_loc << 'Null'
						@add_queue.clear
					end
				elsif mouse_over_queue(mouse_x, mouse_y)
					if @playlist.length > 1
						puts @add_queue
						puts 'add queue'
						x = @add_queue.length()-1
						while x >= 0
							@queue.insert(@song_playing_index + @queue_index, @add_queue[x])
							x -= 1
						end
						@queue_index += @add_queue.length()
						@add_queue.clear
						@playlist.clear
						@playlist_loc.clear
						@playlist << 'Null'
						@playlist_loc << 'Null'
						puts @queue
						puts 'mouse over queue'
					end
				elsif mouse_over_volumn_down(mouse_x, mouse_y)
					if @song.volume > 0.05
						@song.volume -= 0.1
					end
				elsif mouse_over_volumn_up(mouse_x, mouse_y)
					if @song.volume < 0.95
						@song.volume += 0.1
					end
				elsif mouse_over_replay(mouse_x, mouse_y)
					if @replay_time % 2 == 0 or @replay_time == 0
						@replay = true
					else
						@replay = false
					end
					@replay_time += 1
					puts @replay
				end
			else
				if mouse_over_sort_all(mouse_x, mouse_y)
					if !@show_ranking
						@start = true
						@sort_choice = 1
						@order = sorting_main(@albums, @sort_choice)
						puts @order
						@song_playing_index = 1
						@album_number = 1
						@album_number_index = 0
						@album_number = @order[@album_number_index]
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@album_clicked = false
						@page = 1
					end
				elsif mouse_over_sort_year(mouse_x, mouse_y)
					if !@show_ranking
						@start = true
						@sort_choice = 2
						@order = sorting_main(@albums, @sort_choice)
						@song_playing_index = 1
						@album_number_index = 0
						@album_number = @order[@album_number_index]
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@album_clicked = false
						@page = 1
					end
				elsif mouse_over_sort_genre(mouse_x, mouse_y)
					if !@show_ranking
						@start = true
						@sort_choice = 3
						@order = sorting_main(@albums, @sort_choice)
						@song_playing_index = 1
						@album_number = 1
						@album_number_index = 0
						@album_number = @order[@album_number_index]
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@album_clicked = false
						@page = 1
					end
				elsif mouse_over_sort_number_tracks(mouse_x, mouse_y)
					if !@show_ranking
						@start = true
						@sort_choice = 4
						@order = sorting_main(@albums, @sort_choice)
						@song_playing_index = 1
						@album_number = 1
						@album_number_index = 0
						@album_number = @order[@album_number_index]
						@pages = pages_cal(@albums[@album_number].tracks.length - 1)
						@album_clicked = false
						@page = 1
					end
				elsif mouse_over_playlists(mouse_x, mouse_y)
					if !@show_ranking
						if @playlists.length > 1
							@albums2 = @albums
							@albums = @playlists
							@start = true
							@song_playing_index = 1
							@album_number = 1
							@pages = pages_cal(@albums[@album_number].tracks.length - 1)
							@album_clicked = false
							@page = 1
							@playlist_playing = true
						end
					end
				elsif mouse_over_ranking(mouse_x, mouse_y)
					if !@start
						@ranking_name = []
						@view_time = []
						avoid_album_number = []
						avoid_track_number = []
						for i in 1..@albums.length-1
							for j in 1..@albums[i].tracks.length-1
								@view_time << @albums[i].tracks[j].view
							end
						end

						@view_time.sort! {|x, y| y <=> x}

						def include(array, x)
							ans = false
							for i in array
								if x == i
									ans = true
									break
								end
							end
							return ans
						end

						for vt in @view_time
							for i in 1..@albums.length-1
								for j in 1..@albums[i].tracks.length-1
									if include(avoid_album_number, i) == false or include(avoid_track_number, j) == false
										if @albums[i].tracks[j].view == vt
											@ranking_name << @albums[i].tracks[j].name
											avoid_album_number << i
											avoid_track_number << j
										end
									end
								end
							end
						end

						@show_ranking = true
					end

				elsif mouse_over_menu(mouse_x, mouse_y)
					if @show_ranking == true
						@show_ranking = false
						@start = false
						@album_clicked = false
					end
				end
			end

		when Gosu::MsRight
			if @start
				for i in 1..4
					if mouse_over_track(mouse_x, mouse_y, i)
						if @album_clicked
							done = false
							for j in @playlist_loc
								if j == @albums[@album_number].tracks[i + 4*(@page-1)].location.chomp
									done = true
								end
							end
							if done == false
								track = Playlist_Track.new(@albums[@album_number].tracks[i + 4*(@page-1)].name.chomp, @albums[@album_number].tracks[i + 4*(@page-1)].location.chomp, @album_number, i + 4*(@page-1), @albums[@album_number].tracks[i + 4*(@page-1)].seconds)
								@playlist << track
								@playlist_loc << @albums[@album_number].tracks[i + 4*(@page-1)].location.chomp
								@add_queue << i + 4*(@page-1)
							end
						end
					end
				end
			end
		end
	end
end

MusicPlayerMain.new(files).show()
