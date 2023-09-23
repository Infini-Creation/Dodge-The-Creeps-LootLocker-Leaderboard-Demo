extends Control

var leaderboard_entry : PackedScene = preload("res://score_item.tscn")
var initialised : bool = false

@export var submitted_score : int

signal leaderboard_data_loaded
signal back_to_the_game

func init():
	$Debug.text = "init..."
	if initialised == false:
		#error signal already connected !
		leaderboard_data_loaded.connect(_on_lbdata_loaded)
		initialised = true

	#get the 1st three + -2,+2 around the player
	#			get layer rank 1st
	#			get players around using count/after in request
	#still before that change result returned by get leaderboard to take rank as well
	print("get leaderboard data")
	
	#top 3 + -1/+1 rank of current score
	#if total <= 10: get all scores
	# else: scores around player (+/- 3 or 4)
	var result = await LootLocker.leaderboard.get_leaderboard({})
	print("Res="+str(result))

	#loading anim slow because synchronous call, UI stuck while request is issuing !!
	## need async mode => test

	print("LB here="+str(LootLocker.leaderboard.data["scores"]))
	
	#here get rid of rank when they'll be returned with result as they should
	if LootLocker.leaderboard.data["scores"].size() > 0:
		leaderboard_data_loaded.emit()
		
		# if LootLocker.leaderboard.leaderboards.size() > 10:
		# short version +/- 3 around player
		#else:
		#var rank : int = 1	#must use the one from LL for score around player and crowded lb
		var playerName : String
		var color : Color

		$Debug.text = "color "
		for score in LootLocker.leaderboard.data["scores"]:
			var entry = leaderboard_entry.instantiate()
			if score["name"] == "":
				print("name is empty")
				if score["public_uid"] != "":
					playerName = score["public_uid"]
				else:
					print("public_uid is empty")
			else:
				playerName = score["name"]

			if score["rank"] == LootLocker.leaderboard.last_submitted_score_rank:
				color = Color.DARK_TURQUOISE
				$Debug.text += "DT"
			else:
				color = Color.WHITE
				$Debug.text += "w"

			entry.setup(score["rank"], playerName, score["score"])
			entry.highlight_entry(color)
			$VBoxContainer.add_child(entry)
			#rank += 1
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
