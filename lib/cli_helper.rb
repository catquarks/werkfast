module CliHelper

	def CliHelper.number_of_arguments
		if ARGV.first
			return ARGV.first.to_i
		else
			return 1
		end
	end

	def CliHelper.determine_exit_status
		if $?.exitstatus == 0
		  puts "hurray!"
		else
		  puts "oh no!"
		end	
	end

end