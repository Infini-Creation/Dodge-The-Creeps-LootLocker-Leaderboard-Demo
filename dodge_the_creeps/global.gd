extends Node

#"dtc-demo-scores"
const LEADERBOARD_KEY : String = "DTC-LB-min"

const SAVEDIR : String = "user://"
const FILENAME : String = "dtc.data"
const SAVEFILE : String = SAVEDIR + FILENAME


var PLAYER_DATA : Dictionary = {
	"player_name" : "player",
	"SessionToken" : "",
	"player_identifier": "",
	"public_uid": "",
	"player_id": "",
	"_dirty" : []
}

var logged_in : bool = false


func load_player_data() -> void :
	var data_read : String
	
	if !FileAccess.file_exists(SAVEFILE):
		return

	var file = FileAccess.open(SAVEFILE, FileAccess.READ)
	if file != null:
		for item in PLAYER_DATA:
			data_read = file.get_pascal_string ()
			print("load_player_data: "+item+"="+data_read)
			if data_read != "":
				PLAYER_DATA[item] = data_read
		file.close()
	else:
		print("Error opening file: "+str(file.get_error()))


func save_player_data(do_not_save_data : bool = false):
	print("spd called")

	if do_not_save_data == false:
		var file = FileAccess.open(SAVEFILE, FileAccess.WRITE)
		if file != null:
			for item in PLAYER_DATA:
				if item != "_dirty":
					print("save item "+item+"="+str(PLAYER_DATA[item]))
					#if PLAYER_DATA[item] != "": #should check updated flag (to add)
					file.store_pascal_string (str(PLAYER_DATA[item]))
					if file.get_error():
						print("Error storing data ["+item+"]: "+str(file.get_error()))
			file.close()
		else:
			print("Error opening file: "+str(file.get_error()))
			
	print("spd completed")
	#player_data_saved.emit()


func clear_player_data():
	for item in PLAYER_DATA:
		PLAYER_DATA[item] = ""


func login():
	if logged_in == false:
		print("logging in...")
			#input here should be player id (long like bd5d5d12-0cd7-429a-9175-d04406a97eea)
		var result = await LootLocker.guest_login(PLAYER_DATA["player_identifier"])
		if result == OK:
			print("logged in, sessionT="+LootLocker.session.token)
			logged_in = true
			print("PLayerID="+LootLocker.current_user.PLAYERSDATA["player_identifier"])
			print("PLayerName="+LootLocker.current_user.PLAYERSDATA["player_name"])
			PLAYER_DATA["player_identifier"] = LootLocker.current_user.PLAYERSDATA["player_identifier"]
			PLAYER_DATA["player_id"] = LootLocker.current_user.PLAYERSDATA["player_id"]
			PLAYER_DATA["public_uid"] = LootLocker.current_user.PLAYERSDATA["public_uid"]
			PLAYER_DATA["SessionToken"] = LootLocker.session.token

			save_player_data()

			LootLocker.add_leaderboard({"key": LEADERBOARD_KEY, "session-token": LootLocker.session.token})
		else:
			print("ERROR ! Not logged in")
	else:
		print("already looged in")


func logout():
	if logged_in == true:
		LootLocker.session.end_session(LootLocker.session.token)
		logged_in = false
