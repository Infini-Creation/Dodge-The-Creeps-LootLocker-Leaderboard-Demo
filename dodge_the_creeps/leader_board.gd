extends Control

var leaderboard_entry : PackedScene = preload("res://score_item.tscn")

@export var submitted_score : int

signal leaderboard_data_loaded
signal back_to_the_game

func init():
	leaderboard_data_loaded.connect(_on_lbdata_loaded)

	#get the 1st three + -2,+2 around the player
	#			get layer rank 1st
	#			get players around using count/after in request
	#still before that change result returned by get leaderboard to take rank as well
	print("get leaderboard data")
	
	#top 3 + -1/+1 rank of current score
	var result = await LootLocker.leaderboard.get_leaderboard()
	print("Res="+str(result))

	#loading anim slow because synchronous call, UI stuck while request is issuing !!
	## need async mode => test

	print("LB here="+str(LootLocker.leaderboard.leaderboards))
	
	#here get rid of rank when they'll be returned with result as they should
	if LootLocker.leaderboard.leaderboards.size() > 0:
		leaderboard_data_loaded.emit()
		
		var rank : int = 1
		var playerName : String
		for score in LootLocker.leaderboard.leaderboards["dtc-demo-scores"]:
			var entry = leaderboard_entry.instantiate()
			if score["name"] == "":
				print("name is empty")
				if score["public_uid"] != "":
					playerName = score["public_uid"]
				else:
					print("public_uid is empty")
			else:
				playerName = score["name"]
			entry.setup(rank, playerName, score["score"])
			$VBoxContainer.add_child(entry)
			rank += 1
	else:
		pass


func _on_button_pressed():
	#eventually cancel request
	for child_item in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child_item)
		child_item.queue_free()
	back_to_the_game.emit()


func _on_lbdata_loaded():
	print("LB data loaded")
	$"Loading LBData".hide()
