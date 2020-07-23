extends Area2D

func _ready():
	pass

func _on_DialogueBox_body_entered(body):
	get_parent().get_node("YSort/Player").deactived()
	pass 

func _on_DialogueBox_body_exited(body):
	if "YSort/Player" in body.name:
		get_parent().set_process_input(true)
	get_parent().get_node("YSort/Player").activated()
	pass 
