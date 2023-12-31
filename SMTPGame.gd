extends Node2D

var role = "smtp"
var ip_address = "192.168.1.25"
var port = 110
var level = 0
var emails = {}
var subjects = ["Critical Update Required", "Data Anomaly Detected", "Unsanctioned Access Traced", "Cryptic Transaction Pending", "Systemic Integrity Breach", "Virtual Nexus Infiltration", "Neural Interface Alert", "Decryption Protocol Initiated", "Incognito Surveillance Alert", "Binary Echoes Unveiled", "Chrono-Encryption Breach", "Shadow Network Intrusion", "Code Red Surveillance Notice", "Darknet Consortium Summons", "Synchronicity Protocol Violation", "Clandestine Data Exchange Required", "Silent Encryption Compromise", "Chronos Directive Issued", "Echo Chamber Surveillance", "Binary Veil Unraveling"]
var contents = ["The neon pulse of the city conceals the shadows of our transaction—your encrypted memories for the currency of the untraceable.","Within the binary folds of cyberspace, your sins echo louder than you think. We've seen your every digital whisper; the reckoning draws near.","In the heart of the data storm, where lines of code intersect with destiny, your secrets unravel like strands of corrupted DNA. We hold the strands.","The encrypted vault of your subconscious has been breached; your dreams now dance in the neon glow of our servers. Payment is expected promptly.","As the clockwork of the metropolis ticks in binary, so does your fate. The Trojan horse is in; your firewall crumbles like rusted circuitry.","In the catacombs of the virtual underworld, your identity is just another relic waiting to be unearthed. Consider this your digital ransom note.","Data mercenaries are at your doorstep, armed with algorithms and malice. Pay the cryptocurrency toll, or face the cascade of your own undoing.","Your neural pathways, once a sanctuary, now serve as the highways for our information juggernaut. Surrender the encryption key, or prepare for neural overload.","The neural net trembles as our tendrils of deceit spread through the synapses of the unsuspecting. Your reality is a construct; we control the narrative.","In the ghostly corridors of the dark web, a whisper reaches your inbox—a clandestine alliance beckons. Join us, or prepare for the erasure of your existence.","The static hum of corruption permeates your inbox. Your coded secrets are currency in the cyber abyss. We demand payment or watch as your digital self crumbles.","Weaving through the quantum fabric of your digital identity, our viral payload awaits activation. Resistance is futile; surrender to the algorithmic plague.","In the neon-lit underbelly of the net, the data scavengers thrive. Your cache of forbidden knowledge is now in their possession; salvation requires a heavy price.","As the city sleeps, your encrypted sins come alive. The ebon-clad avatars of the underworld demand tribute, or watch your virtual empire burn.","The binary echoes of your darkest deeds resonate in the hidden chambers of the web. The silent whispers of the code demand retribution; your soul is the price.","The encrypted whispers of discontent echo through the cybernetic veins of the city. Choose: be a puppet in our strings, or be lost in the chaos of the virtual uprising.","Within the encrypted folds of this message lies the contract that binds you to the shadows. Embrace the darkness, or watch your illusions of privacy crumble.","The quantum shadows converge, unraveling the threads of your artificial reality. Decrypt the message, or become a casualty in the silent war of the digital insurgency.","The black market of information hungers for your secrets. In the neon-lit alleyways of anonymity, your data is the currency. Pay the toll, or face the void.","In the realm where code meets consciousness, your digital soul is in jeopardy. The malware of fate infects your inbox; salvation lies in the transfer of your virtual wealth."]
var directivesubjects = ["CUR", "DAD", "UAT", "CTP", "SIB", "VNI", "NIA", "DPI", "ISA", "BEU", "CEB", "SNI", "CRS", "DCS", "SPV", "CDR", "SEC", "CDI", "ECS", "BVU"]
var directivecontents = ["neon pulse","binary folds","data storm","encrypted vault","metropolis ticks","virtual underworld","Data mercenaries","neural pathways","neural net","dark web","static hum","quantum fabric","neon-lit underbelly","city sleeps","darkest deeds","encrypted whispers","encrypted folds","quantum shadows","black market","the realm"]
var connections = {}
var currentdirective = ''
var domainnames = ['neon.wn','neural.nn','nexus.vp','crypt.vz', 'pixv.qr', 'maze.cr', 'quant.wn']
var names = ['bill','josh','bob','jake','adam','tyson','coby','mick','oscar','mia','gary','pat','dom','paul','sandy','goku','gojo','nami']
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#5 to start, add more as level up
func _ready():
	rng.randomize()
	for _i in range(5):
		add_mail_item()
	
#Adds an email to the backend list
func add_mail_item():
	var new_subject = "Re: " + subjects.pop_at(randi() % len(subjects))
	var new_contents = contents.pop_at(randi() % len(contents))
	emails[new_subject] = new_contents
	
#Initial keyword hiding - DO NOT USE after game has begun, may overwrite other file contents
func hide_keyword(keyword):
	#generate a random int to pick an element from emails
	var email_subjects = emails.keys()
	var subject = email_subjects[randi() % len(email_subjects)]
	emails[subject] = keyword

func add_keyword(sender, receiver, server, keyword):
	print("pushing " + keyword + " to " + receiver.hacker_name)
	var success = false
	var response_message = "Unable to push/pull keyword. Unknown error."
	if len(emails) > len(receiver.keywords):
		if keyword in sender.keywords:
			var subjects = emails.keys()
			var subject = subjects.pop_front()
			var still_looking = true
			while still_looking:
				if not (emails[subject] in receiver.keywords):
					still_looking = false
					emails[subject] = keyword
					success = true
				if len(subjects) > 0:
					subject = subjects.pop_front()
				else:
					still_looking = false
		else:
			response_message = "Unable to move keyword - sender does not own it."
	else:
		response_message = "Unable to move keyword - insufficient space on receiver."
	if success:
		response_message = "Success. Keyword pushed to " + receiver.hacker_name
		sender.keywords.erase(keyword)
		receiver.keywords.append(keyword)
		server.games[sender.game_ip_address].remove_keyword(keyword)
		server.send_team_details(receiver.team)
	return response_message
		

func remove_keyword(keyword):
	for subject in emails:
		if emails[subject] == keyword:
			emails[subject] = "missing data"

func get_email(subject):
	if emails.has(subject):
		return emails[subject]
		
func list_emails():
	var subjects = emails.keys()
	subjects.shuffle()
	return "\n" + "\n".join(subjects)

func list_connections():
	return "\n" + "\n".join(connections.keys())

func create_directive(player, server):
	var domain = domainnames[randi() % len(domainnames)]
	var recpdomain = domainnames[randi() % len(domainnames)]
	var singlecontent = directivecontents[randi() % len(directivecontents)]
	var singlesubject = directivesubjects[randi() % len(directivesubjects)]
	var fullemail = randomemail()
	var directive = domain + '|' + singlesubject + '|' + fullemail + '|' + recpdomain + '|' + singlecontent
	currentdirective = directive
	server.send_status(player.hacker_name, "directive", directive)

func add_connection(new_ip):
	var ttl = rng.randi_range(15,25)
	connections[new_ip] = ttl
	return str(ttl)

#Remove connection only removes attackers who are connected to this server
#This is passive - attackers are automatically bumped after a time limit
func remove_connection(target_ip, server):
	if connections.has(target_ip):
		connections.erase(target_ip)
		var disconnect_target = server.get_player_by_game_ip(target_ip)
		disconnect_target.game_connection = ""
		server.send_terminal_message(disconnect_target.command_terminal_id, "SMTP: Connection lost!")
	return true

func expire_connections(server):
	var expired = {}
	for connection in connections:
		connections[connection] -= 1
		if connections[connection] <= 0:
			expired[connection] = remove_connection(connection, server)
	return expired
	
#for directive string (domain | sender etc
func randomemail():
	var sendname = names[randi() % len(names)]
	var domainname = domainnames[randi() % len(domainnames)]
	return sendname + '@' + domainname
	
#Generic function - executes whenever the game server ticks (currently once per second)
#The SMTP tick doesn't do too much - it should send a new directive if the old one has been fulfilled
#Occasionally send a directive to allow a phishing email to be sent - say every 45 seconds or so, if one hasn't already been sent
func tick(player, server):
	if currentdirective == '':
		create_directive(player, server)
		expire_connections(server)

#How often should you level up? How often are you rewarded for it?
#Probably once per directive is fine due to the vulnerable nature of the server
func level_up():
	level += 1
	add_mail_item()

#Check for commands that an attacker can use in this function
#You will need to parse two attacker commands: view emails and read <subject>
func parse_attacker_command(command, player, server):
	if command == 'view emails':
		server.send_terminal_message(player.command_terminal_id, list_emails())
	elif command.begins_with('read'):
		var requestedsubject = command.right(5)
		if emails.has(requestedsubject):
			server.send_terminal_message(player.command_terminal_id, emails[requestedsubject])
		else:
			server.send_terminal_message(player.command_terminal_id, 'EMAIL NOT FOUND')
	else:
		server.send_terminal_message(player.command_terminal_id, "INVALID SMTP COMMAND")

#Check for commands that the owner can use in this function
#You will need to parse the following:
#A full HELO etc etc command to compare with the directive and award a big chunk of intel
#port shift (exactly the same code as in telnet)
#spam filter (costs 10 intel, but doubles the opposing teams scan ip/portscan/connection costs for 1 minute)
func parse_command(command, player, server):
	print(command)
	if command == 'test':
		server.change_score(player.team, 1)
		pass
	elif command == "port shift":
		var intel_cost = server.intel_costs["port shift"]
		if server.get_team_intel(player.team) >= intel_cost:
			server.change_intel(player.team, -1 * intel_cost)
			port = rng.randi_range(port+1, port+20)
			server.send_terminal_message(player.game_terminal_id, "Port changed to " + str(port))
			server.play_sound("port_shift")
		else:
			server.send_terminal_message(player.game_terminal_id, "Insufficient intel to shift ports (<"+str(intel_cost)+")")
	else:
		server.send_terminal_message(player.game_terminal_id, "INVALID SMTP COMMAND")
	
	
	
	
	
	
	"""
	if command.begins_with == "HELO"
	
	if command == "show cnx":
		server.send_terminal_message(player.game_terminal_id, list_connections())
	elif command.begins_with("kick "):
		var games = server.games
		var target_ip = command.right(len("kick "))
		if games[player.game_ip_address].remove_connection(target_ip, server):
			server.send_status(player.hacker_name, "game", "TELNET: Malicious connection " + target_ip + " removed - intel gained.")
			server.change_score(player.team, 1)
			games[player.game_ip_address].level_up()
			#Put this in a function ffs - need unified disconnection
			if target_ip in games[player.game_ip_address].external_connections:
				var disconnect_target = server.get_player_by_game_ip(target_ip)
				disconnect_target.game_connection = ""
				games[player.game_ip_address].external_connections.erase(target_ip)
				server.send_terminal_message(disconnect_target.command_terminal_id, "TELNET: Connection lost!")
				server.send_terminal_message(disconnect_target.command_terminal_id, "disconnect")
				server.send_terminal_message(disconnect_target.status_terminal_id, "disconnect")
				server.send_status(disconnect_target.hacker_name, "disconnect", "telnet:" + target_ip)
		else:
			server.send_status(player.hacker_name, "game", "TELNET: Interferred with or removed valid connection " + target_ip + " - intel lost.")
			server.change_score(player.team, -1)
	elif command == "port shift":
		var intel_cost = server.intel_costs["port shift"]
		if server.get_team_intel(player.team) >= intel_cost:
			server.change_intel(player.team, -1 * intel_cost)
			port = rng.randi_range(port+1, port+20)
			server.send_terminal_message(player.game_terminal_id, "Port changed to " + str(port))
			server.play_sound("port_shift")
		else:
			server.send_terminal_message(player.game_terminal_id, "Insufficient intel to shift ports (<"+str(intel_cost)+")")
	else:
		server.send_terminal_message(player.game_terminal_id, "INVALID SMTP COMMAND")
	"""
