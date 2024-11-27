extends CharacterBody2D
signal hit

#Variáveis de movimento
const SPEED = 208.0
const JUMP_VELOCITY = -388.0
var is_jumping := false

#Variáveis de som
var jump_sound_played := false
@onready var running_sfx = $running_sfx as AudioStreamPlayer
@onready var jumping_sfx = $jumping_sfx as AudioStreamPlayer


@onready var animation := $anim as AnimatedSprite2D

@onready var collision_hit_right := $hitbox/collision_hit_right as CollisionShape2D
@onready var collision_hit_left := $hitbox2/collision_hit_left as CollisionShape2D
@onready var attack_timer := $attack_timer as Timer
var is_attacking := false
func _ready() -> void:
	collision_hit_right.disabled = true
	collision_hit_left.disabled = true

@onready var dying_timer := $dying_timer as Timer
var is_dying := false

var is_running := false

func _physics_process(delta: float) -> void:
	if is_attacking:
		return # Interrompe outras animações enquanto o ataque está ativo
	
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Controle de ataque
	if Input.is_action_just_pressed("ui_accept"):
		attack()

	# Controle de pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

		# Tocar o som do pulo apenas uma vez por salto
		if not jump_sound_played:
			jumping_sfx.play()
			jump_sound_played = true
	elif is_on_floor():
		is_jumping = false
		jump_sound_played = false  # Permitir o som no próximo pulo

	# Obter direção do movimento e controlar aceleração/desaceleração
	var direction := Input.get_axis("ui_left", "ui_right")
		
	if direction != 0 and is_dying != true:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		
		if animation.animation != "jumping" and is_attacking != true:
			animation.play("running")
			# Tocar o som de corrida apenas se não estiver tocando
			if not running_sfx.playing:
				running_sfx.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		# Estado idle ou durante o pulo
		if is_jumping:
			animation.play("jumping")
		elif is_attacking == false and is_dying == false:
			animation.play("idle")

		# Parar o som da corrida se o personagem estiver parado ou pulando
		if running_sfx.playing:
			running_sfx.stop()

	move_and_slide()

#func de ataque do player
func attack() -> void:
	if is_attacking:
		return # Evita sobreposição de ataques
	is_attacking = true
	animation.play("attack")
	if get_look_direction() == "right":
		collision_hit_right.disabled = false
	elif get_look_direction() == "left":
		collision_hit_left.disabled = false
	attack_timer.start()
	print("Ataque iniciado")

#funções de interação de morte do mob
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.texture.play("dying")
		body.die()

func get_look_direction() -> String:
	return "right" if animation.scale.x > 0 else "left"


#Funções de interação de morte do jogador
func _on_mob_detector_body_entered(body: Node2D) -> void:
	is_dying = true
	animation.play("dying")
	dying_timer.start()

func die():
	hit.emit()
	print("morto")
	queue_free()

func _on_attack_timer_timeout() -> void:
	collision_hit_right.disabled = true
	collision_hit_left.disabled = true
	is_attacking = false # Permite que outras animações sejam executadas


func _on_dying_timer_timeout() -> void:
	die()
