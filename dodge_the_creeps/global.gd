extends Node

var PLAYER_DATA : Dictionary = {
	"player_name" : "player",
	"SessionToken" : "",
	"player_identifier": "",
	"public_uid": "",
	"player_id": "",
	"_dirty" : []
}

#"dtc-demo-scores"
const LEADERBOARD_KEY : String = "DTC-LB-min"

const SAVEDIR : String = "user://"
const FILENAME : String = "dtc.data"
const SAVEFILE : String = SAVEDIR + FILENAME
