module Cli

	def Cli.number_of_arguments
		if ARGV.first
			return ARGV.first.to_i
		else
			return 1
		end
	end

	def Cli.get_user_answer(question)
		puts question
		answer = STDIN.gets.chomp
		if answer == 'y'
			yield
		elsif answer == 'n'
			Cli.get_user_answer
		else
			puts "Only 'y' or 'n' are good answers!"
			Cli.get_user_answer
		end				
	end	

	class SavePath
		def self.save_path
			save_path = File.open('save_path').read
			save_path == "" ? "/!blank!/!file!/!path!" : save_path.lines.first.chomp
		end
		
		def self.puts_save_path
			puts self.save_path
		end

		def self.is_valid_save_path_file?
			File.exists?('save_path') ? true : false
		end

		def self.get_user_input
			puts "Where would you like to save files?"
			input = STDIN.gets.chomp
			save_path = File.join(Dir.home, '/', input)
			puts "Is #{save_path} okay? y/n"
			answer = STDIN.gets.chomp.downcase
			if answer == 'y'
				`mkdir -p #{save_path} && echo "#{save_path}\n# this is where Werkfast will save your files!\n" > ./save_path`
				puts "Files will be saved in #{save_path}!"
			elsif answer == 'n'
				self.get_user_input
			else
				puts "Only 'y' or 'n' are good answers!"
				self.get_user_input
			end
		end

		def self.create_save_path
			if !self.is_valid_save_path_file?
				File.open('save_path', 'w')
				puts "Creating 'save_path' to save your save path!"
				self.get_user_input
			end

			return self.save_path
		end

	end

	class SearchParams
		def self.search_params
			search_params = File.open('search_params').read
			search_params == "" ? "is:unread" : search_params.lines.first.chomp
		end
		
		def self.puts_search_params
			puts self.search_params
		end

		def self.is_valid_search_params_file?
			File.exists?('search_params') ? true : false
		end

		def self.get_user_input
			puts "What email address do you get work emails from?"
			input = STDIN.gets.chomp
			search_params = "from:#{input} is:unread"
			puts "Is '#{search_params}' okay? y/n"
			answer = STDIN.gets.chomp.downcase
			if answer == 'y'
				`echo "#{search_params}" > ./search_params`
				puts "Emails will be searched using '#{search_params}'!"
				return search_params
			elsif answer == 'n'
				self.get_user_input
			else
				puts "Only 'y' or 'n' are good answers!"
				self.get_user_input
			end
		end

		def self.create_search_params
			if !self.is_valid_search_params_file?
				File.open('search_params', 'w')
				puts "Creating 'search_params' to save your search params!"
				self.get_user_input
			end

			return search_params
		end

	end

end
