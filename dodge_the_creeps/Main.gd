extends Node

@export var mob_scene: PackedScene
@export var mob_min_speed : float = 150.0
@export var mob_max_speed : float = 250.0
@export var default_mob_time : float = 0.5
var score
var do_not_save_data : bool = false


func _ready():
	print("ready called")
	$MobTimer.wait_time = default_mob_time

	Global.load_player_data()
	
	print("data="+str(Global.PLAYER_DATA))

	LootLocker.setup("dev_529b11593cd64732b9c97123913e2ee2", "e6m82yag", "0.0.0.1", true)
	#var lok = LootLockerDataVault.load_sdk_data()
	#print("lok ="+str(lok))
	#setupfromfile should be use to don't need to deal with this ourselves
	#LootLocker.setup(LootLockerDataVault.API_KEY, LootLockerDataVault.DOMAIN_KEY, LootLockerDataVault.GAME_VERSION, true, true)

	Global.login()


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	Global.login()
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


## add bonus (hector)
# effect: invincibility for x secs
#	can eat mobs (contact make them disappear)
#	score * 2 (*3 rarer)
#	+ 5, 10, 15, ... pts bonus
#	repel mobs (harder to add)
#	decrease mob speed
#	 less mobs spwaned (mobitmer increased)
#	tinier mobs


func _on_dontsave_received():
	print("data won't be saved on exit")
	do_not_save_data = true
