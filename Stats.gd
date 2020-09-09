extends Node

export(int) var max_health = 1 setget set_max_health
export(int) var coins = 0 setget set_coins
var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal coins_changed(value)

func set_coins(value):
	coins = value
	emit_signal("coins_changed", coins)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = max_health
	self.coins = coins
