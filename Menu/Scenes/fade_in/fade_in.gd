extends ColorRect
# Затемнение при переходе
signal fade_finished # Объявление сигнала для обращеени к нему

func fade_in():
	$AnimationPlayer.play("fade-in") 

func _on_AnimationPlayer_animation_finished(anim_name):
	# warning-ignore:return_value_discarded
	emit_signal("fade_finished")
