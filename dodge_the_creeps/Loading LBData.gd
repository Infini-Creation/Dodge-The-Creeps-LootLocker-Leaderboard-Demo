extends Label

func _ready():
	var label_tween : Tween = self.create_tween()
	label_tween.set_loops()
	label_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#label_tween.tween_interval(0.5)		#.set_delay(0.02)
	label_tween.tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	label_tween.play()
