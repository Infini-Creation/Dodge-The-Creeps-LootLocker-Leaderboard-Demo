extends Control

@export var Rank : int
@export var Name : String
@export var Score : int


func setup(rank: int, name: String, score : int) -> void:
	Rank = rank
	Name = name
	Score = score
	

func _ready():
	$HBoxContainer/Rank.text = str(Rank)
	$HBoxContainer/Name.text = Name
	$HBoxContainer/Score.text = str(Score)
