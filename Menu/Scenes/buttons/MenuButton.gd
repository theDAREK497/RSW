extends Button

export(String) var scene_to_load
export(String) var scene_name

func _ready():
	$Label.text = tr(scene_name)
	pass
