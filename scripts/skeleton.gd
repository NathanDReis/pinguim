extends CharacterBody2D

enum SkeletonState {
	walk,
	hurt,
}

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector

const SPEED = 30.0
var status: SkeletonState
var direction = 1

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.hurt:
			hurt_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	animated.play("walk")
	
func go_to_hurt_state():
	status = SkeletonState.hurt
	animated.play("hurt")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	
func walk_state(_delta: float):
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
func hurt_state(_delta: float):
	pass

func take_damage():
	go_to_hurt_state()
