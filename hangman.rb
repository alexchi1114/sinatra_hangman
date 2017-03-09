require 'sinatra'
require 'sinatra/reloader'


class Game
	attr_accessor :random_word, :display, :choices, :counter
	def initialize
		@random_word=get_word.downcase
		@display=""
		@random_word.length.times{@display += " ____ "}
		@choices=[]
		@counter=0
	end

	def intro
		puts "\n"+"*Welcome to Alex Chi's Hangman!*"
		puts "If you would like to load the previous game press '0'. If you would like to start a new game press 1."
		choice=gets.chomp
		while (choice!="0"&&choice!="1")
			puts "invalid option. 0 to load previous game, 1 for new game."
			choice=gets.chomp
		end
		case choice
		when "0"
			load_game
		when "1"
			start
		end
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

    def start
		puts "\n"+"You have 10 tries to guess the following word"
		puts "\n"+@display.join("")	

		while @counter<10
			puts "\n"+"Which letter would you like to guess? Or press '1' to save the game."
			puts "Previous guesses:#{@choices}" unless @choices==[]
			choice=gets.chomp.downcase
			while @choices.include? choice
				puts "\n"+"You already picked that letter."
				puts "Choose again:"
				choice=gets.chomp.downcase
			end
	
			if choice=="1"
				puts "your game has been saved."
				save_game
				next
			end

			correct_positions=check_word(random_word, choice)
				if correct_positions==[]
				@counter+=1
				puts "\n"+"That letter is not in the word. Incorrect guesses: #{@counter}"
			end

			correct_positions.each do |value|
				@display[value]=choice+" "
			end

			puts @display.join("")

			if @display.join.gsub(/\s+/, "")==@random_word
				puts "You won!!!!!!!!!"
				@counter=11
			end

			if @counter==10
				puts "Sorry, you lost!"
				puts "The word was #{@random_word}"
			end
			
			@choices << choice
		end
	end
end


get '/' do 
	game = Game.new
	word = game.random_word
	erb :index, :locals => {:display => game.display, :word => word}
end