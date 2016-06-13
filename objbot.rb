puts 'starting felynebot'
print 'loading require...'
require 'json'
require 'discordrb'
require 'rubygems'
require 'sys/uptime'
require 'active_support'
require 'yaml'
include Sys
require 'time'

clock=Time.new

puts "Starting at: "+clock.inspect
puts 'DONE!'
puts 'loading login...'

#Simple prompt for input
def prompt(*args)
    print(*args)
    gets
end


class User
  def initialize(id, name, ign, array, channel, b)
    @usr_id=id
    @usr_name=name
    @usr_ign=ign
    @usr_guild=nil
    @user_timezone=nil

    if array.length==0
      array.push(self)
      b.send_message(channel, "**#{name}** not found in (empty) database, added. IGN: **#{ign}**")
    else
      if array.any?{|a| a.id == id}
        b.send_message(channel, "**#{name}** found in database, skipped.")
      else
        array.push(self)
        b.send_message(channel, "**#{name}** not found in database, added. IGN: **#{ign}**")
      end
    end
  end
#Defining the user id variable (call it with user.id)
  def id
    @usr_id
  end
#Defining the user name variable (call it with user.name)
  def name
    @usr_name
  end
#Defining the user ign variable (call it with user.ign)
  def ign
    @usr_ign
  end
#Defining the user guild variable (call it with user.guild)
  def guild
    @usr_guild
  end
#Defining the user id variable (call it with user.timezone)
  def timezone
    @usr_timezone
  end
end

#Creating the actual user array, loading shall be done here
users=[]


#Open file for token/Get Token
if File.exist?("bot/token")
	puts 'Opened file'
	f = File.open("bot/token","r")
	token = f.read
	f.close
else
	puts 'No file found for the Token String! Please input your token.'
	token = prompt "Token: "

	q= prompt "Store this for next time? y/n: "
	if q[0] == "y"
		if File.exist?("bot/token")
				f = File.open("bot/token","w")
		else
				puts 'Creating new file [bot/token]'
				f = File.new("bot/token","w")
		end
		f.write(token)
		f.close
	end
end

puts '------->Token Loaded!'

#Open file for ID/Get ID
if File.exist?("bot/id")
	puts 'Opened file'
	f = File.open("bot/id","r")
	id = f.read
	f.close
else
	puts 'No file found for the ID String! Please input the ID.'
	id = prompt "Client/Application ID: "

	q= prompt "Store this for next time? y/n: "
	if q[0] == "y"
		if File.exist?("bot/id")
				f = File.open("bot/id","w")
		else
				puts 'Creating new file [bot/id]'
				f = File.new("bot/id","w")
		end
		f.write(id)
		f.close
	end
end

puts '------->ID Loaded!'

#Create the bot object
bot = Discordrb::Commands::CommandBot.new token: token, application_id: id, prefix: '-', advanced_functionality: false
bot.debug = false
puts 'DONE!'



#Experimental
bot.command(:bot, from: "Alice", description: "Output testing") do |event|
  event << "Your wish is my command."
  puts "#{clock.inspect}: #{event.user.name}: -bot"
end

#Add a user to the database (Now with objects!)
bot.command(:adduser,min_args: 1, max_args: 1, description: "Adds a user the the database. -adduser <IGN>", usage: "-adduser <IGN>") do |event, ign|
  puts "#{clock.inspect}: #{event.user.name}: -adduser <#{ign}>"
  tempUser= User.new(event.user.id, event.user.name, ign, users, event.message.channel, bot)
  puts "Command worked"
end

bot.command(:userlist, min_args: 0, max_args: 1, description: "Shows the user database.") do |event, page=1|

  page=page.to_i-1
  if page<0 then page=0 end
  if users.length == 0
    event << "User table is empty!"
  else
    pages=users.length/20
    if pages<1 then pages=1 end
    i=(users.length/pages)*page
    puts "Old: #{i}"
    puts "List is: #{users.length-1}"
    if i>(users.length-1) then i=0 end
    puts "New: #{i}"
    event << "User Database:"
    event << "`Name               IGN                 Guild               Timezone`"
      begin
        str = ""
        if users[i].name!=nil then str << "`#{users[i].name.to_s}" end
        str=str.ljust(20)
        if users[i].ign!=nil then str << "#{users[i].ign.to_s}" end
        str=str.ljust(40)
        if users[i].guild!=nil then str << "#{users[i].guild.to_s}" end
        str=str.ljust(60)
        if users[i].timezone!=nil then str << "#{users[i].timezone.to_s}" end
        if users[i].name!=nil then str << "`" end
        event << str
        i+=1
      end while i < (users.length/pages)*(page+1)
      event << "Showing page #{page+1}/#{pages}"
    end
end


#Load userdatabase
bot.command(:load, description: "Loads user array file.", usage: "-load") do |event|
	if File.exist?("userbase/users")
		puts 'Opened file'
		f = File.open("userbase/users","r")
	else
		puts 'No file!'
    break
	end
	users=YAML.load(f)
	puts 'Loaded user database'
  f.close
end

#save user database
bot.command(:save, description: "Saves user array to file.", usage: "-save") do |event|
	if File.exist?("userbase/users")
		puts 'Opened file'
		File.open("userbase/users", 'w') {|f| f.write(YAML.dump(users)) }
	else
		puts 'Creating new file'
		File.new("userbase/users", 'w') {|f| f.write(YAML.dump(users)) }
	end
	f.close
	puts 'Saved user database'
end

puts 'DONE!'
print 'starting bot...'
bot.run :async
bot.game = '-help'
puts 'DONE!'
puts 'bot is online!'
bot.sync
