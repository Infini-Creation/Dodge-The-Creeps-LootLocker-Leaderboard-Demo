extends Control

@onready var Score : int
signal score_submitted(status: bool)
 
func _ready():
	pass
	#print("submit score: _ready called")

func update_player_puid():
	$VBoxContainer/playerUID.text = Global.PLAYER_DATA["public_uid"]

func set_score(score : int) -> void:
	$VBoxContainer/Label.text = str(score)
	Score = score


func _on_button_pressed():
	Global.PLAYER_DATA["Name"] = $VBoxContainer/LineEdit.text
	var result : int
	
	if LootLocker.current_user.PLAYERSDATA["player_name"] == "" or LootLocker.current_user.PLAYERSDATA["player_name"] != Global.PLAYER_DATA["Name"]:
		print("update player's name")
		# + save name in file
		Global.save_player_data()
		result = await LootLocker.current_user.set_player_name(Global.PLAYER_DATA["Name"])
		if result == OK:
			print("player's name set successfully")
		else:
			print("Error setting player's name !")

	print("Will submit score: "+str(Score)+" from player: "+Global.PLAYER_DATA["player_name"])
	result = await LootLocker.leaderboard.submit_score(Score)
	print("submit_score res="+str(result))
	if result == OK:
		print("score submitted successfully")
		#get rank achieved, update in game HS for display
	else:
		print("Error, score may be not submitted !")
		
	score_submitted.emit(result == OK)


func _on_line_edit_text_submitted(new_text : String):
	Global.PLAYER_DATA["player_name"] = new_text
	print("new name set:"+new_text)
	#in player data, either dirty = [name] or pn updated, then above, only if updated => setname call
	#laos upon login if name != global player name => setname
	if new_text != "":
		$VBoxContainer/Button.disabled = false
	else:
		$VBoxContainer/Button.disabled = true


func _on_line_edit_text_changed(new_text : String):
	if new_text != "":
		$VBoxContainer/Button.disabled = false
	else:
		$VBoxContainer/Button.disabled = true


func _on_line_edit_visibility_changed():
	if $VBoxContainer/LineEdit.is_visible_in_tree() == true:
		print("=>> pn="+Global.PLAYER_DATA["player_name"])
		$VBoxContainer/LineEdit.text = Global.PLAYER_DATA["player_name"]
		if $VBoxContainer/LineEdit.text != "":
			$VBoxContainer/Button.disabled = false
