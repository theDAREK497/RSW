extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var random_number = rng.randi_range(1, 4)
	match random_number:
		1:
			$Sprite.region_rect.position.x = 0
		2:
			$Sprite.region_rect.position.x = 32
		3:
			$Sprite.region_rect.position.x = 64
		4:
			$Sprite.region_rect.position.x = 96

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
