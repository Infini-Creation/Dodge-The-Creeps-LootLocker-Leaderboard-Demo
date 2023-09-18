extends Node

@export var mob_scene: PackedScene
@export var mob_min_speed : float = 150.0
@export var mob_max_speed : float = 250.0
@export var default_mob_time : float = 0.5
var score
var do_not_save_data : bool = false

var ignore_first_close_notification : bool = true

signal player_data_saved

func _init():
	pass


func _ready():
	print("ready called")
	$MobTimer.wait_time = default_mob_time
	
	get_tree().set_auto_accept_quit(false)
	player_data_saved.connect(_on_data_saved)
	$HUD.do_no_save_data_on_exit.connect(_on_dontsave_received)

	load_player_data()
	
	print("data="+str(Global.PLAYER_DATA))

	var lok = LootLockerDataVault.load_sdk_data()
	print("lok ="+str(lok))
	#setupfromfile should be use to don't need to deal with this ourselves
	LootLocker.setup(LootLockerDataVault.API_KEY, LootLockerDataVault.DOMAIN_KEY, LootLockerDataVault.GAME_VERSION, true, true)

	#load/save => easy: load data = something ? Y => replace default
		#then save on exit (old value or new one, like session after is exists

	print("logging in...")
		#input here should be palyer id (long like bd5d5d12-0cd7-429a-9175-d04406a97eea)
	var result = await LootLocker.guest_login(Global.PLAYER_DATA["player_identifier"])
	if result == OK:
		print("logged in, sessionT="+LootLocker.session.token)
		print("PLayerID="+LootLocker.current_user.PLAYERSDATA["player_identifier"])
		print("PLayerName="+LootLocker.current_user.PLAYERSDATA["player_name"])
		Global.PLAYER_DATA["player_identifier"] = LootLocker.current_user.PLAYERSDATA["player_identifier"]
		Global.PLAYER_DATA["player_id"] = LootLocker.current_user.PLAYERSDATA["player_id"]
		Global.PLAYER_DATA["public_uid"] = LootLocker.current_user.PLAYERSDATA["public_uid"]
		Global.PLAYER_DATA["SessionToken"] = LootLocker.session.token
		
		LootLocker.add_leaderboard({"key": Global.LEADERBOARD_KEY, "session-token": LootLocker.session.token})

	else:
		print("ERROR ! Not logged in")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
			print("WM close req notif")
			print("action...")
			
			call_deferred("queue_free")
			
			print("_notification wait...")
			await get_tree().create_timer(1).timeout #tmp  without it, nothing output after "_input wait"
				#with it, "spd called" then... nothing
			print("_notification delay completed, quit") #<= never reached ??
			
			get_tree().quit()
		

func _input(event):
	if event.is_action_pressed("quit"):
		print("quit action")
		
		print("_input wait...")
		await get_tree().create_timer(2).timeout #tmp
		print("_input delay completed, send notif")
		
		#this get very quick and prevent previous statement to be "seen"
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		#pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(mob_min_speed, mob_max_speed), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func load_player_data() -> void :
	var data_read : String
	
	if !FileAccess.file_exists("user://dtc.data"):
		return

	var file = FileAccess.open("user://dtc.data", FileAccess.READ)
	if file != null:
		for item in Global.PLAYER_DATA:
			data_read = file.get_pascal_string ()
			print("load_player_data: "+item+"="+data_read)
			if data_read != "":
				Global.PLAYER_DATA[item] = data_read
		file.close()
	else:
		print("Error opening file: "+str(file.get_error()))


func save_player_data():
	print("spd called")

	if do_not_save_data == false:
		var file = FileAccess.open("user://dtc.data", FileAccess.WRITE)
		if file != null:
			for item in Global.PLAYER_DATA:
				if item != "_dirty":
					print("save item "+item+"="+str(Global.PLAYER_DATA[item]))
					#if Global.PLAYER_DATA[item] != "": #should check updated flag (to add)
					file.store_pascal_string (str(Global.PLAYER_DATA[item]))
					if file.get_error():
						print("Error storing data ["+item+"]: "+str(file.get_error()))
			file.close()
		else:
			print("Error opening file: "+str(file.get_error()))
			
	print("spd completed")
	player_data_saved.emit()


## add bonus (hector)
# effect: invincibility for x secs
#	can eat mobs (contact make them disappear)
#	score * 2 (*3 rarer)
#	+ 5, 10, 15, ... pts bonus
#	repel mobs (harder to add)
#	decrease mob speed
#	 less mobs spwaned (mobitmer increased)
#	tinier mobs

#no called cause close window = "hard kill" maybe, try to add some get_tree().exit_tree
func _on_tree_exiting():
	print("_on_tree_exiting")
	save_player_data()
	
func _exit_tree():
	print("_exit_tree called")

func _on_data_saved():
	print("data saved, quit")
	get_tree().quit()

func _on_dontsave_received():
	print("data won't be saved on exit")
	do_not_save_data = true
