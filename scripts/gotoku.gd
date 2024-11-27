extends CharacterBody2D

const SPEED = 60.0
const JUMP_VELOCITY = -400.0

@onready var wall_detector := $wall_detector as RayCast2D
@onready var solo_detector := $solo_detector as RayCast2D
@onready var texture := $anim as AnimatedSprite2D
@onready var attack_timer := $attack_timer as Timer
@onready var hit_area = $hit_area/collision_hit as CollisionShape2D



var direction = 1
var is_attacking = false
var can_move = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Inverte direção se colidir com uma parede
	if wall_detector.is_colliding() or !solo_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1

	# Define a direção do sprite
	if direction == 1:
		texture.scale.x = -1
		hit_area.position = Vector2(20, -35)  
	else:
		texture.scale.x = 1  
		hit_area.position = Vector2(-20, -35) 

	# Controla o movimento com base em `can_move`
	if can_move:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()

func _on_anim_animation_finished(anim_name: String) -> void:
	# Ação ao finalizar animações específicas
	if anim_name == "dying":
		die()

func die() -> void:
	# Executa a morte do personagem
	direction = 0
	texture.play("dying")
	await get_tree().create_timer(0.3).timeout  # Espera o timeout do timer
	queue_free()

func attack() -> void:
	is_attacking = true
	can_move = false
	hit_area.disabled = false
	texture.play("attacking")
	attack_timer.start()

func get_look_direction() -> String:
	return "right" if texture.scale.x > 0 else "left"

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		attack()
func _on_attack_timer_timeout() -> void:
	texture.play("walking")
	can_move = true
	is_attacking = false
