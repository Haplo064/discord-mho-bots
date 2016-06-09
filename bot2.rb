#TODO add permission setting/removing/adding
#Rage mode Fixendum

puts 'starting felynebot'
print 'loading require...'
require 'json'
require 'discordrb'
require 'rubygems'
require 'sys/uptime'
require 'active_support'
include Sys
require 'time'
puts 'DONE!'
puts 'loading login...'

#Simple prompt for input
def prompt(*args)
    print(*args)
    gets
end

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
				puts 'Opened file'
				f = File.open("bot/token","w")
		else
				puts 'Creating new file'
				f = File.new("bot/token","w")
		end
		f.write(token)
		f.close
		puts 'Saved Token'
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
				puts 'Opened file'
				f = File.open("bot/id","w")
		else
				puts 'Creating new file'
				f = File.new("bot/id","w")
		end
		f.write(id)
		f.close
		puts 'Saved ID'
	end
end

puts '------->ID Loaded!'

#Create the bot object
bot = Discordrb::Commands::CommandBot.new token: token, application_id: id, prefix: '-', advanced_functionality: false
bot.debug = false
puts 'DONE!'
puts 'loading cmds...'

#-------------GLOBAL VARIABLES-------------
rage=0
cmdcount = 0
time = 0
time1 = 0
time2 = 0
time3 = 0
time4 = 0
time5 = 0
name1s = ''
name2s = ''
name3s = ''
name4s = ''
name5s = ''
angryfelyne = ['Stop it!','Whyre you so mean.','Ill get you!','Waaaaaaaaa! ;_;','Stop it!']
ragefelyne = ['Im getting angry!','The rage is building!','Anger... Increasing!','Raaaaaaaaaaa!','Im getting angry!']
rage2felyne = ['IM SO ANGRY!','HATRED FLOWS THROUGH MY VEIGNS!','PIBBISH IS A BAD MAN','HWAAAAAOOOAAAAAAAGH!','IM SO ANGRY!']
monsterarray = ['akura-vashimu', 'baelidae', 'basarios', 'blue-yian-kut-ku', 'bulldrome', 'caeserber', 'cephadrome', 'chramine', 'conflagration-rathian', 'congalala', 'crystal-basarios', 'daimyo-hermitaur', 'doom-estrellian', 'dread-baelidae', 'estrellian', 'gendrome', 'ghost-caeserber', 'giadrome', 'gold-congalala', 'gypceros', 'hypnocatrice', 'ice-chramine', 'iodrome', 'khezu', 'monoblos', 'one-eared-yian-garuga', 'purple-gypceros', 'rathalos', 'rathian', 'red-khezu', 'red-shen-gaoren', 'rock-shen-gaoren', 'shattered-monoblos', 'shen-gaoren', 'shogun-ceanataur', 'silver-hypnocatrice', 'swordmaster-shogun-ceanataur', 'tartaronis', 'tigrex', 'velocidrome', 'yellow-caeserber', 'yian-garuga', 'yian-kut-ku']
users = []
egame = []
egamescore = []
egamehigh = ["Alice",0]


#Method for saving arrays
def save(ar,loc)
	if File.exist?(loc)
		puts 'Opened file'
		f = File.open(loc,"w")
	else
		puts 'Creating new file'
		f = File.new(loc,"w")
	end
	f.write(ar.to_json)
	f.close
	puts "Saved File!"
end

#Method for loading arrays
def load(ar,loc)
	if File.exist?(loc)
		puts 'Opened file'
		f = File.open(loc,"r")
	else
		puts 'No file!'
	end
	buff = f.read
	ar=JSON.parse(buff)
	puts 'Loaded array!'
	return ar
end

#Loading/creating the Userdatabase
puts 'Loading User database'

if File.exist?("userbase/users")
	f = File.open("userbase/users","r")
	puts 'Opened file'
	buff = f.read
	users=JSON.parse(buff)
	puts 'Loaded user database'
else
	puts 'No file, creating user Database.'
	users = [][]
	puts 'Database created!'
end

#-------------PERMISSIONS-------------
puts 'Permarray Creation'
permarray=[]
permarray = load(permarray,"userbase/perm")

pos=0
begin
	bot.set_user_permission(permarray[pos],permarray[pos+1])
	puts "Added #{permarray[pos+2]} as level #{permarray[pos+1]} user"
	pos+=3
end while pos < permarray.length

#-----EXPERIMENTAL--------
bot.command(:bot, permission_level: 1) do |event|
  event << "Your wish is my command."
end


#-----------MESSAGES FROM PEOPLE PLAYING E GAME---------------
bot.message() do |event|
if !egame.empty?
  i=0
  playing=0
  begin
    if egame[i][0]==(event.author.id) && egame[i][1]==true
      playing=1
      player=i
    end
    i+=1
  end while i < egame.length

  if event.content.downcase.include?('e') && playing == 1
    puts "Has an E! #{event.author.name} LOST. -joinword to try again"
    egame[player][1]=false
    event << "You lost #{event.author.name}! Try -joinword to play again!"

    if egame[player][3]>egame[player][2]
      event << "Not as good as your best effort #{event.author.name}: #{egame[player][3]}. You only scored #{egame[player][2]}"
    end
    if egame[player][2]>egame[player][3]
      egame[player][3]=egame[player][2]
      event << "New highscore for #{event.author.name}: #{egame[player][3]}."
      egame[player][2]=0
    end
  end #message doesn't have an e
  if playing == 1 && !event.content.include?('e')
    egame[player][2]+=event.content.length
  end
end
end


#-------E GAME-------------------
bot.command(:joinword, max_args: 0, min_args: 0, description: "Play a game, where you can't use the letter E.") do |event|
found=0
i=0
  if egame.empty?
    puts "epmty"
    #id/playing/score/highscore
    egame.push([event.user.id,true,0,0])
    event << "#{event.author.name} starts to play!"
    event << "-mytotal to see your current score."
    event << "-myhigh to see your best!"
    found=1
    break
  end
i=0
  begin
    if egame[i][0]==(event.author.id) && egame[i][1]==false
      puts "Found, restart"
      egame[i][1]=true
      egame[i][2]=0
      event << "Welcome back #{event.author.name}! Better luck this time!"
      event << "-mytotal to see your current score."
      event << "-myhigh to see your best!"
      found=1
      break
    end
    i+=1
  end while i < egame.length
i=0
  begin
    if egame[i][0]==(event.author.id) && egame[i][1]==true
      puts "Found, still playing"
      event << "You're already playing!"
      found=1
    end
    i+=1
  end while i < egame.length
  if found==0
    puts "not found"
    egame.push([event.user.id,true,0,0])
    event << "#{event.author.name} starts to play!"
    event << "-mytotal to see your current score."
    event << "-myhigh to see your best!"
  end
end

#Commands for egame score checks
bot.command(:mytotal, description: "Get your current score from the Egame.") do |event|
  i=0
  begin
    if egame[i][0]==(event.author.id)
      event << "Your ongoing total is: #{egame[i][2]}"
    end
    i+=1
  end while i < egame.length
end

#Commands for egame score checks
bot.command(:myhigh) do |event|
  i=0
  begin
    if egame[i][0]==(event.author.id)
      event << "Your top total is: #{egame[i][3]}"
    end
    i+=1
  end while i < egame.length
end


#-------------COMMAND ROLEPLAY-------------
bot.command(:rp, permission_level: 1, description: "Perm1: Pretend to be the bot.", usage: "-rp <Text to display>") do |event, *phrase|
  cmdcount += 1
  phrase = phrase.join(' ')
  event << "sent **#{phrase}** to mhodiscussion"
  bot.send_message(122526505606709257, phrase)
  puts 'CMD: roleplay'
end

#------------ADD TIMEZONE/RAID TIME
#-------------COMMAND ADD USER-------------
bot.command(:adduser, max_args: 1, min_args: 1, description: "Add a user to the database.", usage: "-adduser <IGN>") do |event, ingamename|
	cmdcount += 1
	i=0
	found=0

  if users.any?
	   begin
       if users[i][0]==(event.user.id)
         found=1
       end
       i+=1
     end while i < users.length

     if found==1
       event << "Already in the userbase! Use -changeign to edit your IGN"
     else
       users.push([event.user.id,event.user.name,ingamename])
       event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**"
     end
     puts 'CMD: adduser'
     save(users, "userbase/users")
   else
     users.push([event.user.id,event.user.name,ingamename])
   end
 end
#----------Sort array-----------------------
bot.command(:sort, permission_level: 999) do |event|
  users = users.sort {|a,b| a[1] <=> b[1]}
  event << "Done!"
  save(users,"userbase/users")
end

#-----------Drop the username table---------
bot.command(:dropusertable, max_args: 0, min_args: 0, permission_level: 999, description: "Drops the userbase table. Do not touch.") do |event|
	users=users.drop(users.length)
	p users
	save(users, "userbase/users")
end

#-------Hacky command to get id-------------
bot.command(:id, max_args: 0, min_args: 0, permission_level: 999, description: "Perm999: Lazy hack to get my id") do |event|
	event << event.user.id
end

#-----Hacky command to see what the bot sees------
bot.command(:print, max_args: 1, min_args: 1, permission_level: 999, description: "Perm999: Prints to the cmd what the bot sees.") do |event, arg|
	puts arg
end

#-------------FORCE COMMAND ADD USER-------------
bot.command(:fadduser, max_args: 3, min_args: 3, permission_level: 1, description: "Perm1: Forces a user into the database.", usage: "-fadduser <ID> <NAME> <IGN>") do |event, id, uname, ign|
	#Forces the database to add a new user. Only use for testing!
	cmdcount += 1
	users.push([id,uname,ign])
	event << "added **#{id}**, **#{uname}**, **#{ign}**"
	puts 'CMD: forceadduser'
	save(users, "userbase/users")
end

#-------------COMMAND FIND USER-------------
bot.command(:find, max_args: 1, min_args: 0, description: "Finds things in the user database.", usage: "-find <query>, if <query> is blank, it will find yours.") do |event, username=nil|
  cmdcount += 1
  found=0
  event << "Results:"
  if username!=nil
    i=1
    str=[]
  	begin
      if users[i][0]!=nil && users[i][0]==(username.downcase)
        str.push(i) unless  users.include?(i)
      end
      if users[i][1]!=nil && users[i][1].downcase.include?(username.downcase)
        str.push(i) unless  users.include?(i)
      end
      if users[i][2]!=nil && users[i][2].downcase.include?(username.downcase)
        str.push(i) unless  users.include?(i)
      end
      if users[i][3]!=nil && users[i][3].downcase.include?(username.downcase)
        str.push(i) unless  users.include?(i)
      end
      if users[i][4]!=nil && users[i][4].downcase.include?(username.downcase)
        str.push(i) unless  users.include?(i)
      end
  		i+=1
  	end while i < users.length

    if str!=nil
      str = str.uniq
      i=0
      event << "Found User Database:"
      event << "`Name               IGN                 Guild               Timezone`"
    	begin
        var = ""
        if users[str[i]][1]!=nil
          var << "`#{users[str[i]][1].to_s}"

        end
        if users[str[i]][2]!=nil
          while var.length < 20  do
            var << " "
          end
          var << "#{users[str[i]][2].to_s}"

        end
        if users[str[i]][3]!=nil
          while var.length < 40  do
            var << " "
          end
          var << "#{users[str[i]][3].to_s}"

        end
        if users[str[i]][4]!=nil
          while var.length < 60  do
            var << " "
          end
          var << "#{users[str[i]][4].to_s}"
        end
        #Gotta have this last!
        if users[str[i]][1]!=nil
          var << "`"
        end
        event << var
        #event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**, GUILD: **#{users[i][3]}**"
        i+=1
  		end while i < str.length
    end

  #Compare to their id if they leave it blank
  else
    i=1
  	begin
  		if users[i][0]==(event.user.id)
  			found=1
        event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**"
  		end
  	 i+=1
  	end while i < users.length
  end
end

#-------------COMMAND CHANGE IGN-------------
bot.command(:changeign, max_args: 1, min_args: 1, description: "Changes a users IGN in the database.", usage: "-changeign <IGN>") do |event, ingamename="X"|
	#This will kinda screw up if multiple igns have the same id. Hence why the force add username is restricted.
	i=0
  if users.length>1
		begin
			if users[i][0]==(event.user.id)
        event << "Changing Database"
				event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**"
        users[i][2]=ingamename
				event << 'Changed to:'
				event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**"
			break
			end
			i+=1
		end while i < users.length
		save(users, "userbase/users")
  end
end

#-------------COMMAND FORCE REMOVE USERS-------------
bot.command(:fremoveuser, max_args: 1, min_args: 1, permission_level: 1, description: "Perm1: Forces a user from the database.", usage: "-fremoveuser <@NAME>") do |event, number|
	i=0
	number=number[2..number.length-2]
  number=number.to_i
  puts number
		begin
      puts users[i][0]==number
			if users[i][0]==number
				event << "Found #{users[i][0]}"
				front = users[0,i]
				#p front
				back=users.drop(i+1)
				#p back
				users=front.push(*back)
				event << "Forced #{number} from the list."
				break
			end
			i+=1
		end while i < users.length
		save(users, "userbase/users")
	end

#-------------COMMAND REMOVE USERS-------------
bot.command(:removeuser, max_args: 0, min_args: 0, description: "Removes user from the database.", usage: "-removeuser") do |event|
	i=0
	loc=0
		begin
			if users[i][0]==event.user.id
				event << "Found #{users[i][1]}"
				front = users[0,i]
				#p front
				back=users.drop(i+1)
				#p back
				users=front.push(*back)
				event << "Removed"
				break
			end
			i+=1
		end while i < users.length
		save(users, "userbase/users")
	end

#-------------COMMAND ADD GUILD----------------
bot.command(:guild, max_args: 1, min_args: 0, description: "Adds guild for user to the database.", usage: "-guild <guildname>") do |event, guild=nil|
  i=1
  begin
    if users[i][0]==(event.user.id)
      found=1
      users[i][3]=guild
      event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**, Guild:**#{users[i][3]}**"
      save(users,"userbase/users")
    end
    i+=1
  end while i < users.length
end

#-------------COMMAND ADD TIMEZONE----------------
bot.command(:timezone, max_args: 1, min_args: 0, description: "Adds timezone for user to the database.", usage: "-timezone <timezone>") do |event, zone=nil|
  i=1
  begin
    if users[i][0]==(event.user.id)
      found=1
      users[i][4]=zone
      event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**, Zone: **#{users[i][4]}**"
      save(users,"userbase/users")
    end
    i+=1
  end while i < users.length
end

#-------------COMMAND SHOW USERS-------------
bot.command(:user, description: "Shows all users in the database.", usage: "-users", min_args: 0, max_args: 1) do |event, page=nil|

  if page==nil
    page=0
  else
    page=page.to_i-1
  end

  if users.length == 0
    event << "User table is empty!"
    break
  else
  	cmdcount += 1
    pages=users.length/20
    i=(users.length/pages)*page
  	loc=0
    event << "User Database:"
    event << "`Name               IGN                 Guild               Timezone`"
  		begin
        str = ""
        if users[i][1]!=nil
          str << "`#{users[i][1].to_s}"

        end
        if users[i][2]!=nil
          while str.length < 20  do
            str << " "
          end
          str << "#{users[i][2].to_s}"

        end
        if users[i][3]!=nil
          while str.length < 40  do
            str << " "
          end
          str << "#{users[i][3].to_s}"

        end
        if users[i][4]!=nil
          while str.length < 60  do
            str << " "
          end
          str << "#{users[i][4].to_s}"

        end
        #Gotta have this last!
        if users[i][1]!=nil
          str << "`"
        end
        event << str
        #event << "Username: **#{users[i][1]}**, IGN: **#{users[i][2]}**, GUILD: **#{users[i][3]}**"
        i+=1
  		end while i < (users.length/pages)*(page+1)
      event << "Showing page #{page+1}/#{pages}"
  	end
  end


#-------------LOAD ARRAY FROM FILE------------
bot.command(:load, description: "Loads user array file.", usage: "-load") do |event|
	if File.exist?("userbase/users")
		puts 'Opened file'
		f = File.open("userbase/users","r")
	else
		puts 'No file!'
	end
	buff = f.read
	users=JSON.parse(buff)
	puts 'Loaded user database'
end

#-------------WRITE ARRAY TO FILE------------
bot.command(:save, description: "Saves user array to file.", usage: "-save") do |event|
	if File.exist?("userbase/users")
		puts 'Opened file'
		f = File.open("userbase/users","w")
	else
		puts 'Creating new file'
		f = File.new("userbase/users","w")
	end
	f.write(users.to_json)
	f.close
	puts 'Saved user database'
end
#-------------COMMAND TRANS-------------
bot.command(:translation, description: "Shows steps for translation.", usage: "-translation") do |event, _link|
	event << '**1. Use the google translate app. It supports making pictures off your screen.**'
	event << 'https://play.google.com/store/apps/details?id=com.google.android.apps.translate&hl=en'
	event << ''
	event << '**1.1 advanced Google translate guide**'
	event << 'http://monsterhunteronline.in/translation/'
	event << ''
	event << '**2. Try using a OCR (Optical Character Recognition). Use Chinese Simplefied**'
	event << 'http://www.onlineocr.net/'
	event << 'https://www.newocr.com/'
	event << ''
	event << '**2.1 BakaBot does have a translation command. Just type** ``$trans <text>`` (ex. ``$trans 亲爱``)'
	event << ''
	event << '**3. Ask people on this server, in the help channel**'
	event << 'Asakura or ZenonX can probably help you out'
	event << ''
	event << 'Feel free to check our <#126578658423865344> for more info'
end

#-------------COMMAND PING-------------
bot.command(:ping) do |event|
	cmdcount += 1
	event.respond 'Pong!'
	puts 'CMD: ping'
end # ends function

#-------------COMMAND PING-------------
bot.command(:thing) do |event|
	cmdcount += 1
	event.respond 'Thong!'
	puts 'CMD: thing'
end # ends function

#-------------COMMAND PING-------------
bot.command(:ding) do |event|
	cmdcount += 1
	event.respond 'Dong!'
	puts 'CMD: ding'
end

#-------------COMMAND SECRET-------------
bot.command(:secret) do |event|
	cmdcount += 1
	event << '**ping** pings the bot'
	event << '**ding** dings the bot'
	event << '**rage** bot-rage enabled'
	event << '**normal** bot-normal´enabled'
	puts 'CMD: secret'
end

#Note to self: Fix rage tiers.
#-------------COMMAND RAGE-------------
bot.command(:rage) do |event|
	cmdcount += 1
	rage=rage+1
	if rage>0 and rage<10
		bot.profile.avatar = File.open('pic/avatar_angry.jpg')
		event << angryfelyne[rand(3)+1]
	end
	if rage>10 and rage <50
			bot.profile.avatar = File.open('pic/avatar_rage.jpg')
			event << ragefelyne[rand(3)+1]
	end
	if rage >50
		bot.profile.avatar = File.open('pic/avatar_rage2.jpg')
		event << rage2felyne[rand(3)+1]
	end

end

#-------------COMMAND NORMAL-------------
bot.command(:normal) do |event|
	cmdcount += 1
	bot.profile.avatar = File.open('pic/avatar_normal.jpg')
	event << '**BACK TO NORMAL!**'
	puts 'CMD: normal'
end

#-------------COMMAND EXP RESET-------------
bot.command(:time) do |event|
	cmdcount += 1
	t1 = Time.parse('19:00')
	t1 = t1.to_i
	t2 = Time.now
	t2 = t2.to_i
	if t1 > t2
		t3 = t1 - t2
		event << "#{Time.at(t3).strftime('**%H** hours **%M** minutes **%S** seconds')} left until the next exp/gift reset"
	else
		t1 += 86_400
		t3 = t1 - t2
		event << "#{Time.at(t3).strftime('**%H** hours **%M** minutes **%S** seconds')} left until the next exp/gift reset"
	end
	puts 'CMD: exp reset'
end

#-------------COMMAND EXP RESET-------------
bot.command(:reset) do |event|
	cmdcount += 1
	t1 = Time.parse('19:00')
	t1 = t1.to_i
	t2 = Time.now
	t2 = t2.to_i
	if t1 > t2
		t3 = t1 - t2
		event << "#{Time.at(t3).strftime('**%H** hours **%M** minutes **%S** seconds')} left until the next exp/gift reset"
	else
		t1 += 86_400
		t3 = t1 - t2
		event << "#{Time.at(t3).strftime('**%H** hours **%M** minutes **%S** seconds')} left until the next exp/gift reset"
	end
	puts 'CMD: exp reset'
end

#-------------COMMAND MONSTER SEARCH-------------
bot.command(:monster) do |event, mname|

	if mname.length>3
		cmdcount += 1
		output = monsterarray.select { |s| s.include? mname.to_s }
		if output == []
			event << 'No monsters found'
		else
			output.each do |o|
				event << "http://monsterhunteronline.in/monsters/#{o}"
			end
		end
		puts 'CMD: FAQ MONSTER SEARCH'
	else
		event << "Name not long enough."
	end
end

#-------------COMMAND SERVER-------------
bot.command(:server) do |event|
	cmdcount += 1
	channel = event.channel
	channel.send_file File.new('/home/pi/Documents/discord/Felynebot/pic/server.jpg')
	puts 'CMD: FAQ SERVER'
end

#-------------COMMAND ARMOR-------------
bot.command(:armor) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/armor/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ ARMOR'
end

#-------------COMMAND JEWELRY-------------
bot.command(:jewelry) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/jewelry/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ JEWELRY'
end

#-------------COMMAND WEAPONS-------------
bot.command(:weapons) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/weapons/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ WEAPONS'
end

#-------------COMMAND MONSTERS-------------
bot.command(:monsters) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/monsters/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ MONSTERS'
end

#-------------COMMAND QUESTS-------------
bot.command(:quests) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/quests/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ QUESTS'
end

#-------------COMMAND CATS-------------
bot.command(:cats) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/cats/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ CATS'
end

#-------------COMMAND GATHERING-------------
bot.command(:gathering) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/gathering/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ GATHERING'
end

#-------------COMMAND FOOD-------------
bot.command(:food) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/food/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ FOOD'
end

#-------------COMMAND VIP-------------
bot.command(:vip) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/vip/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ VIP'
end

#-------------COMMAND GROUPING-------------
bot.command(:grouping) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/grouping/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ GROUPING'
end

#-------------COMMAND CRAFTING-------------
bot.command(:crafting) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/crafting/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ CRAFTING'
end

#-------------COMMAND MATERIALS-------------
bot.command(:materials) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/materials/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ MATERIALS'
end

#-------------COMMAND WIKI-------------
bot.command(:wiki) do |event|
	cmdcount += 1
	event << 'http://monsterhunteronline.in/'
	event << 'Feel free to check our <#126578658423865344> for more info'
	puts 'CMD: FAQ WIKI'
end

#-------------COMMAND STATS-------------
bot.command(:stats) do |event|
	cmdcount += 1
	event << "```#{cmdcount} commands executed"
	event << "#{p Uptime.uptime} Online```"
	puts 'CMD: stats'
end

#-------------COMMAND INFO-------------
bot.command(:info) do |event|
	cmdcount += 1
	event << "```Ruby Version: #{RUBY_VERSION}"
	event << "Ruby patchlevel: #{RUBY_PATCHLEVEL}"
	event << "Ruby release date: #{RUBY_RELEASE_DATE}"
	event << 'Ruby DevelopmentKit: No Dev Kit (Linux)'
  event << 'Hardware: Raspberry Pi2'
	event << 'Big Thanks to the Bot Community and @meew0'
	event << 'Creator: @ZerO (ask him if there are any questions)'
	event << 'updated: 21.03.2016```'
	puts 'CMD: info'
end

#-------------COMMAND SET MAINSETUP-------------
bot.command(:mainsetup, permission_level: 1) do |event, hours, minutes|
	cmdcount += 1
	h = hours.to_i
	m = minutes.to_i
	time = h * 3600 + m * 60
	puts time
	event.respond "timer set for **#{hours}** hours and **#{minutes}** minutes"
	puts 'CMD: countdown set'
	while time > 0
		sleep 1
		time -= 1
	end
end

#-------------COMMAND GET MHO REMINDER TIME-------------
bot.command(:maintenance) do |event|
	cmdcount += 1
	output = time
	a = output / 3600
	b = (output - a * 3600) / 60
	c = output - a * 3600 - b * 60
	event.respond "**#{a}:#{b}:#{c}** seconds left"
	puts 'CMD: countdown get'
end

#-------------COMMAND GET MHO REMINDER TIME-------------
bot.command(:maint) do |event|
	cmdcount += 1
	output = time
	a = output / 3600
	b = (output - a * 3600) / 60
	c = output - a * 3600 - b * 60
	event.respond "**#{a}:#{b}:#{c}** seconds left"
	puts 'CMD: countdown get'
end

#-------------COMMAND GET RAID TIMERS-------------
bot.command(:raid) do |event|
	cmdcount += 1
	nout = 0
	output1 = time1
	a1 = output1 / 3600
	b1 = (output1 - a1 * 3600) / 60
	c1 = output1 - a1 * 3600 - b1 * 60
	output2 = time2
	a2 = output2 / 3600
	b2 = (output2 - a2 * 3600) / 60
	c2 = output2 - a2 * 3600 - b2 * 60
	output3 = time3
	a3 = output3 / 3600
	b3 = (output3 - a3 * 3600) / 60
	c3 = output3 - a3 * 3600 - b3 * 60
	output4 = time4
	a4 = output4 / 3600
	b4 = (output4 - a4 * 3600) / 60
	c4 = output4 - a4 * 3600 - b4 * 60
	output5 = time5
	a5 = output5 / 3600
	b5 = (output5 - a5 * 3600) / 60
	c5 = output5 - a5 * 3600 - b5 * 60
	if output1 > 0
		event << "#{name1s}(raid1) **#{a1}:#{b1}:#{c1}** seconds left"
		nout += 1
	else
		time1 = 0
		name1s = ''
	end
	if output2 > 0
		event << "#{name2s}(raid2) **#{a2}:#{b2}:#{c2}** seconds left"
		nout += 1
	else
		time2 = 0
		name2s = ''
	end
	if output3 > 0
		event << "#{name3s}(raid3) **#{a3}:#{b3}:#{c3}** seconds left"
		nout += 1
	else
		time3 = 0
		name3s = ''
	end
	if output4 > 0
		event << "#{name4s}(raid4) **#{a4}:#{b4}:#{c4}** seconds left"
		nout += 1
	else
		time4 = 0
		name4s = ''
	end
	if output5 > 0
		event << "#{name5s}(raid5) **#{a5}:#{b5}:#{c5}** seconds left"
		nout += 1
	else
		time5 = 0
		name5s = ''
	end
	event << 'no raids are currently set up' if nout == 0
	puts 'CMD: get raid timer'
end

#-------------COMMAND SET MHO RAID 1-------------
bot.command(:raid1, permission_level: 1) do |event, hours1, minutes1, *name1|
	cmdcount += 1
	name1 = name1.join(' ')
	name1s = name1
	h1 = hours1.to_i
	m1 = minutes1.to_i
	time1 = h1 * 3600 + m1 * 60
	event.respond "raid 1 set **#{hours1}h #{minutes1}m** as **#{name1}**"
	puts 'CMD: raid1 set'
	while time1 > 0
		sleep 1
		time1 -= 1
	end
end

#-------------COMMAND SET MHO RAID 2-------------
bot.command(:raid2, permission_level: 1) do |event, hours2, minutes2, *name2|
	cmdcount += 1
	name2 = name2.join(' ')
	name2s = name2
	h2 = hours2.to_i
	m2 = minutes2.to_i
	time2 = h2 * 3600 + m2 * 60
	event.respond "raid 2 set **#{hours2}h #{minutes2}m** as **#{name2}**"
	puts 'CMD: raid2 set'
	while time2 > 0
		sleep 1
		time2 -= 1
	end
end

#-------------COMMAND SET MHO RAID 3-------------
bot.command(:raid3, permission_level: 1) do |event, hours3, minutes3, *name3|
	cmdcount += 1
	name3 = name3.join(' ')
	name3s = name3
	h3 = hours3.to_i
	m3 = minutes3.to_i
	time3 = h3 * 3600 + m3 * 60
	event.respond "raid 3 set **#{hours3}h #{minutes3}m** as **#{name3}**"
	puts 'CMD: raid3 set'
	while time3 > 0
		sleep 1
		time3 -= 1
	end
end

#-------------COMMAND SET MHO RAID 4-------------
bot.command(:raid4, permission_level: 1) do |event, hours4, minutes4, *name4|
	cmdcount += 1
	name4 = name4.join(' ')
	name4s = name4
	h4 = hours4.to_i
	m4 = minutes4.to_i
	time4 = h4 * 3600 + m4 * 60
	event.respond "raid 4 set **#{hours4}h #{minutes4}m** as **#{name4}**"
	puts 'CMD: raid4 set'
	while time4 > 0
		sleep 1
		time4 -= 1
	end
end

#-------------COMMAND SET MHO RAID 5-------------
bot.command(:raid5, permission_level: 1) do |event, hours5, minutes5, *name5|
	cmdcount += 1
	name5 = name5.join(' ')
	name5s = name5
	h5 = hours5.to_i
	m5 = minutes5.to_i
	time5 = h5 * 3600 + m5 * 60
	event.respond "raid 5 set **#{hours5}h #{minutes5}m** named: **#{name5}**"
	puts 'CMD: raid5 set'
	while time5 > 0
		sleep 1
		time5 -= 1
	end
end

puts 'DONE!'
print 'starting bot...'
bot.run :async
bot.game = '-help'
puts 'DONE!'
puts 'bot is online!'
bot.sync
