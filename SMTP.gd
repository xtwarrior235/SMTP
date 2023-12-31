extends Node2D

var role = "SMTP"
var ip_address = "192.168.1.25"
var port = 25
var level = 0
var environment_variables = {}
var emails = [] 
var possible_variables = {"LANG":"en_AU", "LOGNAME":"Clarence", "HOME":"/home/user", "SHELL":"/bin/qsh", "TERM":"qterm", "USER":"clarence"}
var subjects = ['Hobbies','Sports','Racing','School','Food','Music','Movies','TV Shows','Books','Video Games','Travel','Animals','Nature','Science','Math','Technology','Art','History','Literature','Philosophy','Psychology','Sociology','Economics','Politics','Current Events','Sports News','Entertainment News','Business News','Science News','Health News','Fashion','Beauty','Home and Garden','Parenting','Pets','Money','Travel','Cars','Gadgets','Lifestyle','Hobbies','DIY Projects']
var contents = ['The quick brown fox jumps over the lazy dog.', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae;', 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.', 'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit', 'sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.', 'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet', 'consectetur, adipisci velit.', 'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.', 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.', 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.']
var allowed_prefix = "192.0.3"
var possible_prefixes = ["192.0.3", "128.50", "169.255.15", "100.128"]
var connections = {}
var external_connections = []
var directive = []
var domainnames = ['@gmail.com','@yahoo.com','@brave.net','@dodo.net']
var names = ['bill','josh','bob','jake','adam','tyson','coby','mick','oscar','mia','gary','pat','dom','paul','sandy','goku','gojo','nami']
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#4 for testing, 2 in normal operation
func _ready():
	rng.randomize()
	add_environment_variable()
	add_environment_variable()
	allowed_prefix = possible_prefixes[randi() % possible_prefixes.size()]
	
#Pulls an env var at random and removes it from the possible list, adding it to the actual list
func add_environment_variable():
	var environment_keys = possible_variables.keys()
	var environment_variable = environment_keys[randi() % len(environment_keys)]
	var variable_value = possible_variables[environment_variable]
	environment_variables[environment_variable] = variable_value
	possible_variables.erase(environment_variable)
func add_mail():
	var subject = subjects[randi() % len(subjects)]
	var content = contents[randi() % len(contents)]
	var email = {"subject":subject, "content":content}
	emails.append(email)
	
func set_keyword(keyword):
	#generate a random int to pick an element from emails
	var emailnumber = randi() % len(emails)
	emails[emailnumber]['content'] = keyword

func add_keyword(sender, receiver, server, keyword):
	print("pushing " + keyword + " to " + receiver.hacker_name)
	var success = false
	var response_message = "Unable to push/pull keyword. Unknown error."
	if len(environment_variables) > len(receiver.keywords):
		if keyword in sender.keywords:
			var environment_variable_names = environment_variables.keys()
			var environment_variable_name = environment_variable_names.pop_front()
			var still_looking = true
			while still_looking:
				print(environment_variable_name + " " + environment_variables[environment_variable_name])
				print(receiver.keywords)
				if not (environment_variables[environment_variable_name] in receiver.keywords):
					still_looking = false
					environment_variables[environment_variable_name] = keyword
					success = true
				if len(environment_variable_names) > 0:
					environment_variable_name = environment_variable_names.pop_front()
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
	for environment_variable_name in environment_variables:
		if environment_variables[environment_variable_name] == keyword:
			environment_variables[environment_variable_name] = "missing data"

func get_variable(environment_variable):
	if environment_variables.has(environment_variable):
		return environment_variables[environment_variable]
		
func list_environment_variables():
	var env_vars = environment_variables.keys()
	env_vars.shuffle()
	return "\n" + "\n".join(env_vars)

func list_connections():
	return "\n" + "\n".join(connections.keys())

func get_octet():
	return str(rng.randi_range(1,254))   

func add_connection(new_ip):
	var connection_ip = false
	if new_ip == "dummy":
		if randi() % 3 == 1:
			connection_ip = get_octet() + "." + get_octet() + "." + get_octet() + "." + get_octet()
		else:
			var octet_array = [allowed_prefix]
			for _i in range(3-allowed_prefix.count(".")):
				octet_array.append(get_octet())
			connection_ip = ".".join(octet_array)
		if !connections.has(connection_ip):
			connections[connection_ip] = rng.randi_range(15,25)
		return connection_ip
	else:
		external_connections.append(new_ip)
		var ttl = rng.randi_range(15,25)
		connections[new_ip] = ttl
		return str(ttl)

func remove_connection(target_ip, server):
	var good_move = false
	if connections.has(target_ip):
		if !target_ip.begins_with(allowed_prefix):
			good_move = true
		connections.erase(target_ip)
	if external_connections.has(target_ip):
		var disconnect_target = server.get_player_by_game_ip(target_ip)
		disconnect_target.game_connection = ""
		external_connections.erase(target_ip)
		server.send_terminal_message(disconnect_target.command_terminal_id, "TELNET: Connection lost!")
	return good_move

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
	return sendname + domainname
#Generic function - executes whenever the game server ticks (currently once per second)
func tick(player, server):
	var items = expire_connections(server)
	for item in items:
		if items[item]:
			server.send_status(player.hacker_name, "game", "Intel lost to " + item)
			server.change_intel(player.team, -1)
		else:
			server.send_status(player.hacker_name, "game", "Intel gained from " + item)
			server.change_score(player.team, 1)
	if player.wait_time <= 0:
		player.wait_time = rng.randi_range(5,15)

		var criteria = get_criteria()
		if player.criteria != criteria:
			player.criteria = criteria
			server.message_random_team_mate(player, "TELNET @ " + player.game_ip_address + ": " + criteria)
		var connection_ip = add_connection("dummy")
		if connection_ip:
			server.send_status(player.hacker_name, "game","TELNET: New inbound connection!")
func get_criteria():
	return "accept all connections from " + allowed_prefix

func level_up():
	level += 1
	if level % 5 == 0:
		add_environment_variable()

#Check for commands that an attacker can use in this function
func parse_attacker_command(command, player, server):
	if command == "env":
		server.send_terminal_message(player.command_terminal_id, list_environment_variables())
	elif command.begins_with("printenv"):
		var arguments = command.split(" ")
		if len(arguments) == 2 and environment_variables.has(arguments[1]):
			server.send_terminal_message(player.command_terminal_id, get_variable(arguments[1]))
	else:
		server.send_terminal_message(player.command_terminal_id, "INVALID TELNET COMMAND")

#Check for commands that the owner can use in this function
func parse_command(command, player, server):
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
	else:
		server.send_terminal_message(player.game_terminal_id, "INVALID TELNET COMMAND")
		
