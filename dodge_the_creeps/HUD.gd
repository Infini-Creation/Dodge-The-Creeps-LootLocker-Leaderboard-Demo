extends CanvasLayer

const GAME_TITLE = "Dodge the\nCreeps"

signal start_game
signal do_no_save_data_on_exit

var score : int
var playerName : String
var leaderboard

func _ready():
	$SubmitScore.score_submitted.connect(_on_score_submitted)
	$LeaderBoard.back_to_the_game.connect(_on_comeback)


func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = GAME_TITLE
	$MessageLabel.show()
	$LeaderBoard.init()
	await get_tree().create_timer(1.5).timeout
	
	$MessageLabel.hide()
	$ScoreLabel.hide()
	$SubmitScore.show()
	$SubmitScore.set_score(score)
	
	#wait or signal to second/last part of game_over (SB show below)
	#here first show submit score panel
	
	#get submit score ok
	#display leader_board scene
	
	
	
	#await get_tree().create_timer(5).timeout #tmp
	#$StartButton.show()


func update_score(new_score):
	$ScoreLabel.text = str(new_score)
	score = new_score


func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()


func _on_score_submitted(status : bool) -> void:
	print("score submitted, st="+str(status))
	$SubmitScore.hide()
	$ResetButton.hide()
	$LeaderBoard.show()


func _on_comeback() -> void:
	print("get back in the game")
	$LeaderBoard.hide()
	$MessageLabel.text = GAME_TITLE
	$MessageLabel.show()
	$StartButton.show()
	$ResetButton.show()


func _on_reset_button_pressed():
	print("Reset saved player data")
	#later? add confirm popup Y/N
	do_no_save_data_on_exit.emit()
	var dir = DirAccess.open("user://")
	if dir != null:
		var error = dir.remove("dtc.data")
		if error != OK:
			print("Failed to delete data file: "+str(error))
		else:
			print("player data file removed")
		#need a way to prevent game to save data back on exit !
	else:
		print("Failed to open user data directory: "+str(DirAccess.get_open_error()))
