require 'sinatra'
#require 'sinatra/reloader'

configure do
  enable :sessions
  set :session_secret, "secret"
end

class Game
	attr_accessor :random_word, :display, :choices, :counter
	
	#def history
	#	alphabet = ("a".."z").to_a
	#end

	def initialize
		@random_word=get_word.downcase
		@display=[]
		@random_word.length.times{@display << " _ "}
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

	def guess_word(string)
		if string == '' || string ==nil
			return nil
		elsif string.downcase==self.random_word
			return true
		else
			return false
		end
	end

	def verify(word, guess)
		message = ''
		guess = guess.downcase unless guess == nil
		if choices.include?(guess)
			message = "That letter has already been chosen!"
		elsif ("a".."z").to_a.include?(guess)==false
			message="That's not a letter!"
		elsif check_word(word, guess)==[]
			message = "Sorry! That letter is not in the word!"
			choices << guess
			@counter+=1
		elsif check_word(word, guess)!=[]
			message = "Nice! That letter is in the word!"
			choices << guess
		end
		
		message
	end

	def modify_display(word, guess)
		correct_positions = check_word(word, guess)
		correct_positions.each do |value|
			@display[value]=guess+" "
		end
	end
end

def new_game
	game = Game.new
	game
end

get '/' do
	if session[:game] == nil
		redirect to('/reset')
	else
		redirect to('/play')
	end
end

get '/play' do 

	session[:word] = session[:game].random_word
	session[:guess] = params['guess']
	session[:word_guess] = params['word_guess']
	session[:message] = ''
	session[:word_guess_message] = ''

	if session[:game].guess_word(session[:word_guess])==nil
		session[:word_guess_message] = ''
	elsif session[:game].guess_word(session[:word_guess])==true
		redirect to('/win')
	else
		session[:word_guess_message] = 'That is wrong!'
		session[:game].counter+=1
	end

	if session[:guess]==''
		session[:message] = ''
	elsif session[:guess]==nil
		session[:message]=='Welcome!'
	elsif
		session[:message] = session[:game].verify(session[:word], session[:guess])
	end
	
	session[:counter] = session[:game].counter
	
	session[:game].modify_display(session[:word], session[:guess])
	session[:display] = session[:game].print_display
	session[:choices] = session[:game].choices

	if session[:display].delete(" ") == session[:word]
		redirect to('/win')
	end
	if session[:counter] == 6
		redirect to('/lose')
	end
	
	erb :index, :locals => {:display => session[:display], :word => session[:word], :choices => session[:choices], :message => session[:message], :counter => session[:counter], :word_guess_message => session[:word_guess_message]}
end

get '/new' do
	game = Game.new
	redirect to('/')
end

get '/reset' do
	session[:game] = new_game
	redirect to '/play'
end

get '/win' do
	session[:display] = session[:game].random_word
	erb :win, :locals => {:display => session[:display], :counter => session[:counter]}
end

get '/lose' do
	session[:display] = session[:game].random_word
	erb :lose, :locals => {:display => session[:display], :counter => session[:counter]}
end

#prompt if letter has already been chosen
#prompt if not a valid guess
#indicate when correct guess is provided and state how many letters are correct.
#keep track of incorrect and prompt when lost
#prompt when win
#create button to start game
#create button for new game if loss or win.
#Create directions


