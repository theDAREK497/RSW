extends Control

var scene_path_to_load

func _ready():
	for button in $Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])


func _on_Button_pressed(scene_to_load):
	$FadeIn.show()
	$FadeIn.fade_in()
	scene_path_to_load = scene_to_load


func _on_FadeIn_fade_finished():
	$FadeIn.hide()
	# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path_to_load)


func _on_Exit_pressed():
	get_tree().quit()
