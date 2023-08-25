extends Control

#var MainScreen : PackedScene = preload("res://Main.tscn")
var leaderboard_entry : PackedScene = preload("res://score_item.tscn")

@export var submitted_score : int

signal leaderboard_data_loaded
signal back_to_the_game

func init(): #not in this function => called almost first in the game !!
	#var lok = LootLockerDataVault.load_sdk_data()
	#print("lok ="+str(lok))
	#LootLocker.setup(LootLockerDataVault.API_KEY, LootLockerDataVault.DOMAIN_KEY, LootLockerDataVault.GAME_VERSION, true, true)
	#print("logging in...")
	#var result = await LootLocker.guest_login(Global.PLAYER_DATA["player_identifier"])
	#print("Res="+str(result))
	#if result == OK:
		#print("logged in, sessionT="+LootLocker.session.token)
		#print("PLayerID="+LootLocker.current_user.PLAYERSDATA["player_identifier"])
		#print("PLayerName="+LootLocker.current_user.PLAYERSDATA["player_name"])
		#Global.PLAYER_DATA["player_identifier"] = LootLocker.current_user.PLAYERSDATA["player_identifier"]
		#Global.PLAYER_DATA["player_id"] = LootLocker.current_user.PLAYERSDATA["player_id"]
		#Global.PLAYER_DATA["public_uid"] = LootLocker.current_user.PLAYERSDATA["public_uid"]
		#Global.PLAYER_DATA["SessionToken"] = LootLocker.session.token
#
		#LootLocker.leaderboard.session_token = LootLocker.session.token
		#LootLocker.leaderboard.leaderboard_key = "dtc-demo-scores" #or id 16636 => save in sdk data
#
	leaderboard_data_loaded.connect(_on_lbdata_loaded)
	#else:
		#print("ERROR ! Not logged in")

	#get the 1st three + -2,+2 around the player
	#			get layer rank 1st
	#			get players around using count/after in request
	#still before that change result returned by get leaderboard to take rank as well
	print("get leaderboard data")
	
	#diplay a loading text (maybe blinking while LB data not available)
	
	# on init, anim is not smooh at all
	#await get_tree().create_timer(5).timeout
	
	#top 3 + -1/+1 rank of current score
	var result = await LootLocker.leaderboard.get_leaderboard()
	print("Res="+str(result))

	#loading anim slow because synchronous call, UI stuck while request is issuing !!
	## need async mode => test
	##await get_tree().create_timer(5).timeout
	
	print("LB here="+str(LootLocker.leaderboard.leaderboards))
	
	#here get rid of rank when they'll be returned with result as they should
	if LootLocker.leaderboard.leaderboards.size() > 0:
		leaderboard_data_loaded.emit()
		
		var rank : int = 1
		var name : String
		for score in LootLocker.leaderboard.leaderboards["dtc-demo-scores"]:
			var entry = leaderboard_entry.instantiate()
			if score["name"] == "":
				print("name is empty")
				if score["public_uid"] != "":
					name = score["public_uid"]
				else:
					print("public_uid is empty")
			else:
				name = score["name"]
			entry.setup(rank, name, score["score"])
			$VBoxContainer.add_child(entry)
			rank += 1
	else:
		pass


func _on_button_pressed():
	#eventually cancel request
	back_to_the_game.emit()


func _on_lbdata_loaded():
	print("LB data loaded")
	$"Loading LBData".hide()
