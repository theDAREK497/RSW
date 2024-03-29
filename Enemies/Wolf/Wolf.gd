extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 0
export var FRICTION = 200

var numFlag = 0

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
	SUFFER_DAMAGE,
	DIE
}

var knockback = Vector2.ZERO
var state = CHASE
var velocity = Vector2.ZERO
var facingDirection = 0
var facingDirectionFlag = "Right"
var readyTimer : float

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

onready var playerDetectionArea = $PlayerDetectionArea
onready var playerDetectionAreaCollision = $PlayerDetectionArea/CollisionShape2D
onready var hitRange = $HitboxPivot/Hitbox
onready var hitRangeCollision = $HitboxPivot/Hitbox/CollisionShape2D
onready var hitboxRange = $HitboxRange/HitboxRange/CollisionShape2D

func _ready():
	state = pickRandomState([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	readyTimer += 1
	
	numFlag += 1
	
	match state:
		IDLE:
			idleState(delta)
			
		WANDER:
			wanderState(delta)
			
		CHASE:
			chaseState(delta)
			
		ATTACK:
			attackState()
			
		SUFFER_DAMAGE:
			sufferDamageState()
			
		DIE:
			dieState()
	
	checkForCollisions(delta)

func idleState(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	sprite.play("Idle")
	seekPlayer()
	if wanderController.get_time_left() == 0:
		pickRandomStateStartWanderTimer()

func wanderState(delta):
	sprite.play("Run")
	seekPlayer()
	if wanderController.get_time_left() == 0:
		pickRandomStateStartWanderTimer()
	accelerateTowardsPoint(wanderController.target_position, delta)
	
	var wanderTargetRange = int(round(global_position.distance_to(wanderController.target_position)))
	if  wanderTargetRange <= 4:
		pickRandomStateStartWanderTimer()

func chaseState(delta):
	if playerDetectionArea.player != null:
		#Get the vector between us and the player
		accelerateTowardsPoint(playerDetectionArea.player.global_position, delta)
		sprite.play("Run")
		
		if (hitRange.player != null):
			sprite.stop()
			state = ATTACK
	else:
		state = IDLE
	sprite.flip_h = velocity.x < 0
	facingDirection = velocity.x

func attackState():	
	if (readyTimer >= 100):
		readyTimer = 0
		velocity = Vector2.ZERO
		sprite.play("Attack")
	#else:
		#velocity = Vector2.ZERO
		#sprite.play("Idle")

func sufferDamageState():
	print("Entered sufferDamageState(): ", numFlag)
	velocity = Vector2.ZERO
	sprite.play("Hit")

func dieState():
	velocity = Vector2.ZERO
	hitRangeCollision.disabled = true
	playerDetectionAreaCollision.disabled = true
	sprite.play("Die")

func checkForCollisions(delta):
	if softCollision.is_colliding():
		velocity += softCollision.getPushVector() * delta * 400
	velocity = move_and_slide(velocity)

func pickRandomStateStartWanderTimer():
	state = pickRandomState([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func accelerateTowardsPoint(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
	#sprite.flip_h = velocity.x < 0
	if (enemyShouldChangeDirection() and sprite.flip_h):
		hitRangeCollision.position *= Vector2(-1,1)
		playerDetectionAreaCollision.position *= Vector2(-1,1)
		hitboxRange.position *= Vector2(-1,1)
		changeFlag()

#Returns TRUE if the enemy moves towards a direction 
#that he wasn't already looking at
func enemyShouldChangeDirection() -> bool:
	return (velocity.x < facingDirection and facingDirectionFlag != "Left") or (
		velocity.x > facingDirection and facingDirectionFlag != "Right")

#if the flag == "Right", change it to "Left" and viceversa
func changeFlag():
	if facingDirectionFlag == "Left":
		facingDirectionFlag = "Right"
	else:
		facingDirectionFlag = "Left"

#If the enemy can see the player, change the state to CHASE
#canSeePlayer() returns true when the player enters the playerDetectionArea
func seekPlayer():
	if playerDetectionArea.can_see_player():
		state = CHASE

#Pick a random state between WANDER and IDLE
func pickRandomState(stateList):
	stateList.shuffle()
	return stateList.pop_front()

#Destroy the object, only when the AnimatedSprite emits the signal animation_finished()
func destroyEnemy():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)

func _on_Stats_noHealth():
	sprite.stop()
	state = DIE

func _on_Hurtbox_invincibility_started():
	if (stats.health > 0):
		sprite.stop()
		sprite.play("Hit")
	pass

func _on_Hurtbox_invincibility_ended():
	if (stats.health > 0):
		sprite.stop()
	pass

func _on_AnimatedSprite_animation_finished():
	if (sprite.animation == "Attack"):
		hitboxRange.disabled = true
	
	if (sprite.animation == "Hit"):
		print("Finished Hit Animation: ", numFlag)
	
	if (stats.health > 0):
		state = IDLE
	else:
		destroyEnemy()

#in the fourth frame of the Attack animaton, 
#enable the hitBox to deal damage to the player
#it's disabled in the animation finished method
func _on_AnimatedSprite_frame_changed():
	if (sprite != null and sprite.animation != null and sprite.frame != null):
		#print("RANGE DISABLED: ", hitboxRange.disabled)
		if (sprite.animation == "Attack" and sprite.frame == 4):
			hitboxRange.disabled = false
		else:
			hitboxRange.disabled = true
