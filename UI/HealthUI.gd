extends Control

var hearts = 3 setget set_hearts
var max_hearts = 3 setget set_max_hearts
var armor = 2 setget set_armor
var max_armor = 2 setget set_max_armor
var coins = 0 setget set_coins
const MAXCOINS = 999

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var armorUIFull = $ArmorUIFull
onready var armorUIEmpty = $ArmorUIEmpty
onready var coinsUI = $CoinCounter

func set_coins(value):
	coins = value
	if coinsUI != null:
		coinsUI.text = String(coins)

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15

func set_armor(value):
	armor = clamp(value, 0, max_armor)
	if armorUIFull != null:
		armorUIFull.rect_size.x = armor * 15

func set_max_armor(value):
	max_armor = max(value, 1)
	self.armor = min(armor, max_armor)
	if armorUIEmpty != null:
		armorUIEmpty.rect_size.x = max_armor * 15

func _ready():		
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	self.max_armor = PlayerStats.max_armor
	self.armor = PlayerStats.armor
	self.coins = PlayerStats.coins
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("armor_changed", self, "set_armor")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_armor_changed", self, "set_max_armor")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("coins_changed", self, "set_coins")
