extends CharacterBody2D
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D


var SPEED = 300.0
var JUMP_VELOCITY = -700.0
var velocidade_queda = 7000

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += Vector2(0,velocidade_queda) * delta

	if Input.is_action_pressed("pulo") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	if velocity.x > 0:
		animacao.flip_h = false
	elif velocity.x < 0:
		animacao.flip_h = true

	move_and_slide()
