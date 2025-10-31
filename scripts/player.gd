extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	dead,
}

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var max_count_jump = 2
@export var max_speed = 180.0
@export var acceleration = 500
@export var deceleration = 600
@export var slide_deceleration = 50

const JUMP_VELOCITY = -300.0

var direction = 0
var jump_count = 0
var status: PlayerState
	
func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)
	
	move_and_slide()


func go_to_idle_state():
	status = PlayerState.idle
	animated.play("idle")

func go_to_jump_state():
	status = PlayerState.jump
	animated.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	animated.play("fall")

func go_to_walk_state():
	status = PlayerState.walk
	animated.play("walk")

func go_to_duck_state():
	status = PlayerState.duck
	animated.play("duck")
	set_small_collider()


func exit_from_duck_state():
	set_large_collider()
	
func go_to_slide_state():
	status = PlayerState.slide
	animated.play("slide")
	set_small_collider()
	
func exit_from_slide_state():
	set_large_collider()

func go_to_dead_state():
	status = PlayerState.dead
	animated.play("dead")
	velocity = Vector2.ZERO

func idle_state(delta: float):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func jump_state(delta: float):
	move(delta)
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state(delta: float):
	move(delta)
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func walk_state(delta: float):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return

func duck_state(_delta: float):
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func slide_state(delta: float):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return

func dead_state(_delta: float):
	pass

func move(delta: float): 
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		animated.flip_h = true
	elif direction > 0:
		animated.flip_h = false

func can_jump() -> bool: 
	return jump_count < max_count_jump

func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		# inimigo morre
		area.get_parent().take_damage()
	else:
		# player morre
		go_to_dead_state()
