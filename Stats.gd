extends Node

export(int) var max_health = 1 setget set_max_health
export(int) var max_armor = 1 setget set_max_armor
export(int) var coins = 0 setget set_coins
var health = max_health setget set_health
var armor = max_armor setget set_armor

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal armor_changed(value)
signal max_armor_changed(value)
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

func set_max_armor(value):
	max_armor = value
	self.armor = min(armor, max_armor)
	emit_signal("max_armor_changed", max_armor)

func set_armor(value):
	armor = value
	emit_signal("armor_changed", armor)

func _ready():
	self.health = max_health
	self.armor = max_armor
	self.coins = coins
