extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_collision_shape: CollisionShape2D = $attack_area/attack_collision_shape
@onready var health_bar: ProgressBar = $"../CanvasLayer/health_bar"

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const damage = 10

var hp = 100
func take_damage(amount: int) -> void:
	hp -= amount
	health_bar.value = hp
	if hp <= 0:
		queue_free()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	attack_collision_shape.disabled = true
	animated_sprite.play("idle")
	

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("attack"):
		animated_sprite.play("attack")

	if animated_sprite.animation == "attack":
		if animated_sprite.frame == 0:
			attack_collision_shape.disabled = false
		else:
			attack_collision_shape.disabled = true

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction < 0:
		animated_sprite.flip_h = true
		attack_collision_shape.position.x = -10
		
	elif direction > 0:
		animated_sprite.flip_h = false
		attack_collision_shape.position.x = 10
		
	if direction:
		animated_sprite.play("move")
		velocity.x = direction * SPEED
	else:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "enemy1":
		body.take_damage(damage)
