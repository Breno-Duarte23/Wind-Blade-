extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -400.0
@onready var wall_detector := $wall_detector as RayCast2D
@onready var texture := $anim as Sprite2D

var direction = 1

func die():
	texture.play("dying")
	await get_tree().create_timer(0.5).timeout  # Espera o timeout do timer
	get_node("collision").set_deferred("disabled", true)
	queue_free()
	
func _on_anim_animation_finished(anim_name: String) -> void:
	if anim_name == "dying":
		die()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1

	if direction == 1:
		$anim.scale.x = -1  
	else:
		$anim.scale.x = 1  

	velocity.x = direction * SPEED

	move_and_slide()
