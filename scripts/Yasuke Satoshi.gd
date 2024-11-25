extends CharacterBody2D
signal hit

const SPEED = 208.0
const JUMP_VELOCITY = -388.0
var is_jumping := false
@onready var animation := $anim as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):
		print("Ataque")
		animation.play("attack")

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.scale.x = direction

		if is_on_floor():
			animation.play("running")
	elif is_jumping:
		animation.play("jumping")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")

	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Colisão do ataque")
	if body.is_in_group("enemies"):
		body.anim.play("dying")


func _on_mob_detector_body_entered(body: Node2D) -> void:
	animation.play("dying")
	die()

func die():
	hit.emit()
	print("morto")
	queue_free()
	
