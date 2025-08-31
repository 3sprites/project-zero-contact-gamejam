extends CharacterBody2D


const SPEED = 20.0
const damage = 10

var hp = 50
var direction = 0
var player = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_collision_shape: CollisionShape2D = $attack_area/attack_collision_shape
@onready var health_bar: ProgressBar = $health_bar
@onready var timer: Timer = $Timer
@onready var detection_sound: AudioStreamPlayer2D = $detection_sound

var can_attack = true
var can_move = false

func take_damage(amount: int) -> void:
	hp -= amount
	health_bar.value = hp
	if hp <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	if player and not can_move:
		animated_sprite.play("detection")
	
	elif player and can_move:
		var x_diff = position.x - player.position.x
		if x_diff > 17:
			animated_sprite.play("move")
			direction = -1
			animated_sprite.flip_h = true
			attack_collision_shape.position.x = -10
		elif x_diff < -17:
			animated_sprite.play("move")
			direction = 1
			animated_sprite.flip_h = false
			attack_collision_shape.position.x = 10
		else:
			if x_diff > 0:
				animated_sprite.flip_h = true
				attack_collision_shape.position.x = -10
			if x_diff < 0:
				animated_sprite.flip_h = false
				attack_collision_shape.position.x = 10
				
			direction = 0
			if can_attack:
				animated_sprite.play("attack")
				timer.start()
				if animated_sprite.frame == 3:
					attack_collision_shape.disabled = false
				else:
					attack_collision_shape.disabled = true
				
			
	else:
		direction = 0
		animated_sprite.play("idle")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

#detection area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "player1":
		detection_sound.play()
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "player1":
		player = null

#attack_area
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "player1":
		body.take_damage(damage)

func _on_timer_timeout() -> void:
	can_attack = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		can_attack = false
	if animated_sprite.animation == "detection":
		can_move = true
