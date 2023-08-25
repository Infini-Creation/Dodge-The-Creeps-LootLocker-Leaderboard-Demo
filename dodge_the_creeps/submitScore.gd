extends Control

#@onready var playerName : String = ""
@onready var Score : int
#signal player_name_changed(newName: String)
signal score_submitted(status: bool)
 
func _ready():
	$VBoxContainer/LineEdit.text = Global.PLAYER_DATA["Name"]
	if $VBoxContainer/LineEdit.text != "":
		$VBoxContainer/Button.disabled = false


func set_score(score : int) -> void:
	$VBoxContainer/Label.text = str(score)
	Score = score


func _on_button_pressed():
	Global.PLAYER_DATA["Name"] = $VBoxContainer/LineEdit.text

	print("Will submit score: "+str(Score)+" from player: "+Global.PLAYER_DATA["Name"])
	var result = await LootLocker.leaderboard.submit_score(Score)
	print("submit_score res="+str(result))
	if result == OK:
		print("score submitted successfully")
		#get rank achieved, update in game HS for display
	else:
		print("Error, score may be not submitted !")
		
	score_submitted.emit(result == OK)
	
	#if playerName != "":
		#player_name_changed.emit(playerName)

	$VBoxContainer.hide()


func _on_line_edit_text_submitted(new_text : String):
	Global.PLAYER_DATA["Name"] = new_text
	print("new name set:"+new_text)
	if new_text != "":
		$VBoxContainer/Button.disabled = false
	else:
		$VBoxContainer/Button.disabled = true


func _on_line_edit_text_changed(new_text : String):
	if new_text != "":
		$VBoxContainer/Button.disabled = false
	else:
		$VBoxContainer/Button.disabled = true
