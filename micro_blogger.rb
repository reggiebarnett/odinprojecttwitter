require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def run
		puts "Welcome to the JSL Twitter Client"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
			when 'q' then puts "Goodbye!" 
			when 't' then tweet(parts[1..-1].join(" "))
			when 'dm' then dm(parts[1],parts[2..-1].join(" "))
			when 'spam' then spam_my_followers(parts[1..-1].join(" "))
			when 'elt' then everyones_last_tweet
			when 's' then shorten(parts[1])
			when 'turl' then tweet(parts[1..-2].join(" ")+' '+shorten(parts[-1]))
			else
				puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def tweet(message)
		if(message.length <= 140)
			@client.update(message)
		else
			puts "Tweet too long"
		end
	end

	def dm(target,message)
		puts "Trying to send #{target} this direct message"
		puts message
		#screen_names = @client.followers.collect{|follower| @client.user(follower).screen_name}
		if followers_list.include? target
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "You can only DM people who follow you"
		end
	end

	def followers_list
		screen_names = @client.followers.collect{|follower| @client.user(follower).screen_name}
	end

	def spam_my_followers(message)
		list = followers_list
		list.each { |f| dm(f,message)}
	end

	def everyones_last_tweet
		friends = @client.friends.collect{|friend| @client.user(friend)}
		friends.each do |friend|
			timestamp = friend.status.created_at
			puts "@#{friend.screen_name} on #{timestamp.strftime("%A, %b %d")}: #{friend.status.text} "
			puts " "
		end
	end

	def shorten(original_url)
		bitly = Bitly.new('hungryacademy','R_430e9f62250186d2612cca76eee2dbc6')
		puts "Shortening this URL: #{original_url}"
		bitly.shorten(original_url).short_url
	end
end

blogger = MicroBlogger.new
blogger.run

