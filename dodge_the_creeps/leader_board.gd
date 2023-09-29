extends Control

var leaderboard_entry : PackedScene = preload("res://score_item.tscn")
var initialised : bool = false

@export var submitted_score : int

signal leaderboard_data_loaded
signal back_to_the_game

func init():
	$Debug.text = "init..."
	if initialised == false:
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

	var lb_data_to_use : String = LootLocker.leaderboard.DEFAULT_DATASET

	if LootLocker.leaderboard.data["scores"].size() > 0:
		leaderboard_data_loaded.emit() #shift it later below when lb is fully ready
		
		if LootLocker.leaderboard.total() > 10:
			if LootLocker.leaderboard.last_submitted_score_rank <= 7:
				#display the ten 1st
				print("LB contains more than 10 entries, but rank <= 7")
				pass
			else:
				print("LB contains more than 10 entries, rank > 7")
				result = await LootLocker.leaderboard.get_leaderboard({"count": 3})
				print("get1st3 Res="+str(result))
					
				#display the 1st 3 + 3 around players
				print("call get scores around player")
				# maybe 2 LB data: abs (nth scores from x to y) and around (player rk +- N)
				# args could be just N or N1,N2 for fine tunning
				result = await LootLocker.leaderboard.get_scores_around_player({"countBefore": 3, "countAfter": 3})
				print("Res="+str(result))
				
				lb_data_to_use = LootLocker.leaderboard.SCORES_AROUND_PLAYERS_RANK
		else:
			#display the ten 1st
			print("LB contains less than 10 entries")
			pass

		$Debug.text = "color "
		print("data = "+str(LootLocker.leaderboard.data))
		if LootLocker.leaderboard.data.has(lb_data_to_use):
			print("LB data contains key")
		else:
			print("LB data DOES NOT contains key")

		# Add the 3 first entries ! ONLY!! if rank > 4
		if LootLocker.leaderboard.data.has(lb_data_to_use):
			if lb_data_to_use == LootLocker.leaderboard.SCORES_AROUND_PLAYERS_RANK:
				print("Add the first three first")

			#issue when rank ~= 7 or so (at least 7 trigger the issue)
			# if statemet wrongly put
				if LootLocker.leaderboard.last_submitted_score_rank > 6:
					var itemCount : int = 0
					for score in LootLocker.leaderboard.data[LootLocker.leaderboard.DEFAULT_DATASET]:
						if score != null:
							create_leaderboard_entry(score, $VBoxContainer)
						else:
							print("null entry, ignored")

						itemCount += 1
						if itemCount >= 3:
							break
						print("add entry "+str(itemCount))
						
					create_leaderboard_entry({"name": " --- ", "rank": -1, "score": -1}, $VBoxContainer)
			
			for score in LootLocker.leaderboard.data[lb_data_to_use]:
				if score != null:
					create_leaderboard_entry(score, $VBoxContainer)
				else:
					print("null entry, ignored")
				#var entry = leaderboard_entry.instantiate()
				#if score != null:
					#if score["name"] == "":
						#print("name is empty")
						#if score["public_uid"] != "":
							#playerName = score["public_uid"]
						#else:
							#print("public_uid is empty")
					#else:
						#playerName = score["name"]
#
					#if score["rank"] == LootLocker.leaderboard.last_submitted_score_rank:
						#color = Color.DARK_TURQUOISE
						#$Debug.text += "DT"
					#else:
						#color = Color.WHITE
						#$Debug.text += "w"
#
					#entry.setup(score["rank"], playerName, score["score"])
					#entry.highlight_entry(color)
					#$VBoxContainer.add_child(entry)
				#else:
					#print("null entry, ignored")
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


func create_leaderboard_entry(data: Dictionary, container : Node):
	var playerName : String
	var color : Color

	$Debug.text = "color "

	var entry = leaderboard_entry.instantiate()
	if data.size() > 0:
		if data["name"] == "":
			print("name is empty")
			if data["public_uid"] != "":
				playerName = data["public_uid"]
			else:
				print("public_uid is empty")
		else:
			playerName = data["name"]

		if data["rank"] == LootLocker.leaderboard.last_submitted_score_rank:
			color = Color.DARK_TURQUOISE
			$Debug.text += "DT"
		else:
			color = Color.WHITE
			$Debug.text += "w"
		
		entry.setup(data["rank"], playerName, data["score"])
		entry.highlight_entry(color)
		container.add_child(entry)
	else:
		print("empty entry data, ignored")
