extends Node
class_name LootLockerLeaderBoard

#const LEADERBOARDS_URL = LootLocker.LOOTLOCKER_API_BASE_URL + "game/leaderboards/"
	#+leaderboard_key+"/list?count=10"

const DEFAULT_SIZE : int = 10
const DEFAULT_DATASET : String = "scores"
const SCORES_AROUND_PLAYERS_RANK : String = "around"

@export var session_token : String = ""
@export var player : LootLockerPlayer
@export var leaderboard_key : String = ""
@export var leaderboard_id : String = ""
#one object = one LB, this should be better !

var data : Dictionary
var last_submitted_score_rank : int = -1
var top_scores = {}
var scores_around_player = {}

#TODO: hide implementation with get_keys/get_smth functions

func _ready():
	print("LootLockerLeaderBoards: _ready called")


func init(args : Dictionary) -> int:
	var status : int = OK
	var idk : String = ""

	if args != null and args.size() > 0:
		if args.has("id") and args["id"] != -1:
			idk = str(args["id"])
			leaderboard_id = idk
		elif args.has("key") and args["key"] != "":
			idk = args["key"]
			leaderboard_key = args["key"]
		else:
			print("[add_leaderboard]: parameter error, id or key is needed !")
			status = ERR_UNCONFIGURED
			
		if args.has("session-token") and args["session-token"] != "":
			session_token = args["session-token"]
		else:
			print("[add_leaderboard]: parameter error, session token is missing !")
		status = ERR_UNCONFIGURED

		if args.has("player") and args["player"] != null:
			player = args["player"]
		#else:
			#print("[add_leaderboard]: parameter error, player is missing !")
		#status = ERR_UNCONFIGURED

	else:
		print("[add_leaderboard]: parameter error !")
		status = ERR_UNCONFIGURED
	
	#maybe a call from LeadeeBoards class to hide what's inside ! (init_lb() )
	data = {"idk": idk, "total": -1, "scores": []}
	data["scores"].resize(DEFAULT_SIZE)
	
	return status


func check_key():
	if leaderboard_key == "":
		print("[check_key]: no key defined")
		return ERR_UNCONFIGURED
	else:
		print("[check_key]: ok")
		return OK

#to report to main repo !!
func total():
	var total : int = -1

	if data != null and data.size() > 0:
		if data.has("total"):
			total = data["total"]
	
	return total


#func token(token : String):
	#session_token = token

#or leaderboard_id int param
#session token + lb key => as property, remove from arg list
#session_token : String, leaderboard_key : String = "", 
#HERE: get rid of lkey/lid, not good here or as last opt args
# need a better args list, dic ?
#pagination_cursor : int = 1, count : int = 10, after : int = -1, key : String = leaderboard_key, id : String = leaderboard_id
func get_leaderboard(args : Dictionary) -> int:
	
	var status : int = OK
	print("[get_leaderboard]: begin")
	LootLockerHelpers.dump_args(args)

	if args != null and typeof(args) == TYPE_DICTIONARY and args.size() > 0:
		pass
	else:
		args = {"count": 10, "after": -1, "pagination_cursor": 1}

	var headers : Array = ["Content-Type: application/json"]

	if !args.has("pagination_cursor"):
		args["pagination_cursor"] = 1
	if !args.has("count"):
		args["count"] = 10
	if !args.has("after"):
		args["after"] = -1
	if !args.has("storage"):
		args["storage"] = DEFAULT_DATASET
	else:
		if args["storage"] != DEFAULT_DATASET and args["storage"] != SCORES_AROUND_PLAYERS_RANK:
			args["storage"] = DEFAULT_DATASET

	if session_token != "":
		headers.append("x-session-token: "+session_token)
	else:
		print("[get_leaderboard]: no session token provided")
		status = ERR_INVALID_DATA
		#return
	#if leaderboard_key != "":
		#print("[get_leaderboard]: leaderboard key="+leaderboard_key)
	#else:
		#print("[get_leaderboard]: no leaderboard_key provided")
		#status = ERR_INVALID_DATA
		#return

	#maybe generic build URL from list of items, take care of convert all to string + check all ok
	var url = Constants.LEADERBOARDS_URL+leaderboard_key+"/list?count=" + str(args["count"])
	if args["after"] != -1:
		print("after is in use")
		url += "&" + Constants.LEADERBOARDS_AFTER_EP_URL + "=" + str(args["after"])
		print("URL="+url)
	var result = await LootLocker.lootLockerUtils.send_http_request(url, headers, HTTPClient.METHOD_GET, {}, {"pagination": "", "items": ""})
	print("[get_leaderboard]: result="+str(result))
	
	#need to return LB data as well or fill in some object here (current LB)
	if result.size() > 0:
		if data == null:
			data = {}
		if result.has("pagination"):
			if result["pagination"].has("total"):
				data["total"] = result["pagination"]["total"]
			else:
				print("[get_leaderboard]: total item not found in result !")
				data["total"] = -1

		if result.has("items"):
			print("fill local data with items regardless of pagination")
			#data["scores"] = Array()
			if result["items"].size() > DEFAULT_SIZE:
				data[args["storage"]].resize(result["items"].size())

			var arrayIdx = 0
			
			#"highlight" current player rank in results
			# rank is the index of the returned array, 1st item idx 0 = rk 1...
			# ONLY for first page, after that rank = idx + delta !

			for item in result["items"]:
				print("process item"+str(item))
				if item.has("rank"):
					data[args["storage"]][arrayIdx] = Dictionary()
				if item.has("score"):
					data[args["storage"]][arrayIdx]["score"] = int(item["score"])
				if item.has("player") and typeof(item["player"]) == TYPE_DICTIONARY and item["player"].size() > 0:
					data[args["storage"]][arrayIdx]["rank"] = item["rank"]
					#if item["player"].has("name") and item["player"]["name"] != "":
					data[args["storage"]][arrayIdx]["name"] = item["player"]["name"]
					#if item["player"].has("public_uid") and item["player"]["public_uid"] != "":
					data[args["storage"]][arrayIdx]["public_uid"] = item["player"]["public_uid"]
					#print("id type="+str(typeof(item["player"]["id"])))
					#if item["player"].has("id") and item["player"]["id"] != null:
					data[args["storage"]][arrayIdx]["id"] = item["player"]["id"]
					print("id type="+str(typeof(item["metadata"])))
					#if item.has("metadata") and item["metadata"] != "":
					data[args["storage"]][arrayIdx]["metadata"] = item["metadata"]
				arrayIdx += 1

	print("[get_leaderboard]: LB="+str(data))

	print("[get_leaderboard]: end")
	
	return status


func submit_score(score : int, metadata : String = "") -> int:

	var ckr = check_key()
	if ckr != OK:
		return ckr

	var data = { "score": str(score), "metadata": metadata }
	var headers : Array = ["Content-Type: application/json", "x-session-token:"+session_token]

	print("[submit_score]: begin")

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.LEADERBOARDS_URL+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, data, {"rank": true})
	print("[submit_score]: result="+str(result))

	if result != null and typeof(result) == TYPE_DICTIONARY and result.size() > 0:
		if result.has("rank"):
			last_submitted_score_rank = result["rank"]

	print("[submit_score]: end")
	return OK


func get_top_scores(count : int = 3) -> int:
	var status : int = OK
	
	print("[get_top_scores]: begin")
	
	status = await get_leaderboard({"pagination_cursor": 1, "count": count})
	
	print("[get_top_scores]: end")
	
	return status


#count : int = 3, countBefore : int = 3, countAfter : int = countBefore
func get_scores_around_player(args : Dictionary = {}) -> int:
	var status : int = OK
	print("[get_scores_around_player]: begin")
	LootLockerHelpers.dump_args(args)

	var ckr = check_key()
	if ckr != OK:
		return ckr

	var headers : Array = ["Content-Type: application/json"]
	
	if session_token != "":
		headers.append("x-session-token: "+session_token)
	else:
		print("[get_scores_around_player]: no session token provided")
		status = ERR_INVALID_DATA
		return ERR_INVALID_DATA
	if player == null:
		print("[get_scores_around_player]: player instance not yet initialized")
		status = ERR_UNCONFIGURED
		return ERR_UNCONFIGURED

	if args.size() > 0:
		if !args.has("countBefore"):
			args["countBefore"] = 3
		if !args.has("countAfter"):
			args["countAfter"] = 3

	# add how many to keep from scores
	# replace scores with those around player's rank
	# resize array if needed !

	#curl -X GET "https://api.lootlocker.io/game/leaderboards/1/member/1" lastp = player_id
	print("[get_scores_around_player]: get player's rank 1st")
	var player_id = player.PLAYERSDATA["player_id"]
	var url = Constants.LEADERBOARDS_URL + leaderboard_key + Constants.LEADERBOARDS_MEMBER_EP_URL + "/" + str(player_id)
	var result = await LootLocker.lootLockerUtils.send_http_request(url, headers, HTTPClient.METHOD_GET, {}, {"all": true})
	print("[get_scores_around_player]: result="+str(result))
	#{ "rank": 8, "member_id": "4812874", "score": 962757, "player": { "name": "newname11", "id": 4812874, "public_uid": "GXTLLY6C" }, "metadata": "" }
	
	if result != null and typeof(result) == TYPE_DICTIONARY and result.size() > 0:
		if result.has("rank"):
			print("rank is: "+str(result["rank"]))
		else:
			print("rank not found in result !")
			return ERR_INVALID_DATA
	else:
		print("invalid data received from previous call")
		return ERR_INVALID_DATA

	#suggested by Johannes from LL team
	#curl -X GET "https://api.lootlocker.io/game/leaderboards/1/list?count=10&after=49"
	
	#+ if rank = 1 or less than countBefore ? (cb=3 and rk= 2 for instance)
	#do this ONLY if leaderboard contains enough scores !
	var count = args["countBefore"] + args["countAfter"] + 1
	
	#need lb here! or just count
	if data.size() > 0:
		print("data s > 0")
		if data.has("total"):
			print("total is set")
			data["around"] = []
			data["around"].resize(count)
			
			if data["total"] < count:
				print("total["+str(data["total"])+"] < count ["+str(count)+"]")
				print("[get_scores_around_player]: there is not enough scores yet in leaderboard: "+str(count)+"/"+str(data["total"]))
				
				if data["total"] == -1:
					print("no data available, get LB")
					result = await get_leaderboard({})
					print("res="+str(result))
				
				# fill around data with already fetched leaderboard data
				data["around"] = data["scores"]
			else:
				print("total["+str(data["total"])+"] > count ["+str(count)+"]")

				var after : int
				
				#
				if result["rank"] <= args["countBefore"]:
					print("player's rank <= CB")
				else:
					print("player's rank > CB")
					after = result["rank"] - ceili(count / 2.0)
					print("after="+str(after))
					print("rk="+str(result["rank"])+"  c="+str(count)+" c/2="+str(ceili(count / 2.0))+ "  aft="+str(after))
					print("=============get scores around player rank==============")
					result = await get_leaderboard({"pagination_cursor": 1, "count": count, "after": after, "storage": "around"})
			# compare total vs cb+ca+1
			# less or more ?
			
			#if result["rank"] <= args["countBefore"]:
				#after = 1
				#count = args["countBefore"] + args["countAfter"] + 1 #same as above ???
			#else:
				#
#
			#if after < 0:
				#print("after is negative !")
				###after = countBefore + countAfter
				##shift after to 1- -before+before (ex -3+3 => 1-6)
		##rk=8 c=6 aft=7 ??
		##	should be 5  rk-3 rk+3
		##	but here cb/ca = 2 => cb+ca=4 => rk-2,rk+2
				
			#else:
				#print("after > 0")
		else:
			print("total is not set yet (???)")
	#put data somewhere !!
	print("[get_scores_around_player]: end")
	
	return status
