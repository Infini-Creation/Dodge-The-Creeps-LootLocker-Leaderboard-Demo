extends Control

@export var Rank : int
@export var Name : String
@export var Score : int


func setup(rank: int, playerName: String, score : int) -> void:
	Rank = rank
	Name = playerName
	Score = score


func _ready():
	$HBoxContainer/Rank.text = str(Rank)
	$HBoxContainer/Name.text = Name
	$HBoxContainer/Score.text = str(Score)


func highlight_entry(color: Color) -> void:
	$HBoxContainer/Rank.set("theme_override_colors/font_color", color)
	$HBoxContainer/Name.set("theme_override_colors/font_color", color)
	$HBoxContainer/Score.set("theme_override_colors/font_color", color)
