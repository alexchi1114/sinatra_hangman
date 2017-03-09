require 'sinatra'
require 'sinatra/reloader'


class Game
	attr_accessor :random_word, :display, :choices, :counter
	def initialize
		@random_word=get_word.downcase
		@display=[]
		@random_word.length.times{@display << " ____ "}
		@choices=[]
		@counter=0
	end

	def print_display
		@display.join(" ")
	end

    def get_word
		dictionary=File.open("dictionary.txt", "r").readlines.each{|line| line}
		search=true
		while search==true
			random_word=dictionary[rand(0...dictionary.length)].gsub(/\s+/, "")
			if (random_word.length<13 && random_word.length>4)
				search=false
				return random_word
			else
				search=true
			end

		end
	end

	def check_word(word, guess)
		index_array=[]
		word.split("").each_with_index do |letter, index|
			if letter==guess
				index_array << index
			end
		end
		return index_array
	end

	def modify_display(word, guess)
		correct_positions = check_word(word, guess)
		correct_positions.each do |value|
			@display[value]=guess+" "
		end
	end
end

game = Game.new
word = game.random_word

get '/' do 
	guess = params['guess']
	game.modify_display(word, guess)
	display = game.print_display
	erb :index, :locals => {:display => display, :word => word}
end



