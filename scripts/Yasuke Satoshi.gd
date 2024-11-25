extends CharacterBody2D


const SPEED = 208.0
const JUMP_VELOCITY = -388.0
var is_jumping := false
var jump_sound_played := false  # Flag para controlar o som do pulo
@onready var animation := $anim as AnimatedSprite2D
@onready var running_sfx = $running_sfx as AudioStreamPlayer
@onready var jumping_sfx = $jumping_sfx as AudioStreamPlayer


func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta


	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

		# Tocar o som do pulo apenas uma vez por salto
		if not jump_sound_played:
			jumping_sfx.play()
			jump_sound_played = true

	elif is_on_floor():
		is_jumping = false

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.scale.x = direction

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		# Estado idle ou durante o pulo
		if is_jumping:
			animation.play("jumping")
		else:
			animation.play("idle")
		
		# Parar o som da corrida 
		# se o personagem estiver parado ou pulando
		if running_sfx.playing:
			running_sfx.stop()

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
	
