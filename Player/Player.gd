extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
const MINUTE = 60000

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK,
	BLOCK
}

var state = MOVE
var velocity = Vector2.ZERO
var analog_velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var current_stage = "NONE"
var next_stage = "NONE"
var is_active = true
var shield_timer = 0

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state()
		
		ATTACK:
			attack_state()
		
		BLOCK:
			move_state(delta)

func move_state(delta):
	if is_active == true:
		var input_vector = Vector2.ZERO
		if analog_velocity != Vector2.ZERO:
			input_vector.x = analog_velocity.x
			input_vector.y = analog_velocity.y
		else: 
			input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		input_vector = input_vector.normalized()
		
		if Input.is_action_just_pressed("block"):
			state = BLOCK
		
		if Input.is_action_just_released("block"):
			state = MOVE
		
		if (state == BLOCK) and (stats.armor <= 0):
			state = MOVE
			stats.armor = 0
		
		if shield_timer == MINUTE/100:
			stats.armor += 1
			shield_timer = 0
		
		if input_vector != Vector2.ZERO:
			roll_vector = input_vector
			swordHitbox.knockback_vector = input_vector
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationTree.set("parameters/Attack/blend_position", input_vector)
			animationTree.set("parameters/Roll/blend_position", input_vector)
			animationTree.set("parameters/RunBlock/blend_position", input_vector)
			animationTree.set("parameters/IdleBlock/blend_position", input_vector)
			if state == BLOCK:
				animationState.travel("RunBlock")
				velocity = velocity.move_toward(input_vector * MAX_SPEED/2, ACCELERATION * delta)
			else:
				animationState.travel("Run")
				velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			if state == BLOCK:
				animationState.travel("IdleBlock")
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			else:
				animationState.travel("Idle")
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		move()
		
		shield_timer += 1
		
		if Input.is_action_just_pressed("roll"):
			state = ROLL
		
		if Input.is_action_just_pressed("attack"):
			state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if state == BLOCK:
		stats.armor -= area.damage
	else:
		stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	
func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func analog_force_change(inForce, inAnalog):
	if(inAnalog == "Left_Analog"): 
		analog_velocity.x = inForce.x
		analog_velocity.y = -inForce.y

func _on_Attack_pressed():
	state = ATTACK

func _on_Roll_pressed():
	state = ROLL

func _on_Block_pressed():
	state = BLOCK

func _on_Block_released():
	state = MOVE

func _on_Area2D_body_entered(body, extra_arg_0):
	if body.is_in_group("Player"):
		go_next_stage()
		next_stage = extra_arg_0

func go_next_stage():
	get_node("/root/World/Camera2D/FadeIn").show() 
	get_node("/root/World/Camera2D/FadeIn").fade_in()
	
func deactived():
	is_active = false
	velocity.x = 0
	animationTree.set("parameters/Idle/blend_position", Vector2.ZERO)
	
func activated():
	is_active = true

func _on_FadeIn_fade_finished():
	current_stage = get_tree().get_current_scene().get_name()
	# warning-ignore:return_value_discarded
	get_tree().change_scene(next_stage)
	# warning-ignore:return_value_discarded
	get_node("/root/World/Camera2D/FadeIn").hide()

func _on_Coin_coin_collected(value):
	stats.coins += 1
