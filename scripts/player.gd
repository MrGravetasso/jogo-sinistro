extends CharacterBody2D
@onready var animacao: AnimatedSprite2D = $animaçao


var SPEED = 35000.0
var JUMP_VELOCITY = -700.0
var velocidade_queda = 8000

func _physics_process(delta: float) -> void:
#Gravidade
	if not is_on_floor():
		velocity += Vector2(0,velocidade_queda) * delta

	mover(delta)

	move_and_slide()

func mover(delta):

#Faz o pulo estilo hollow knight
	if velocity.y > 0:
		return
	else:
		pular()

#Vai para os lados
	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = 0
#Ajusta a animação para o lado correto
	if velocity.x > 0:
		animacao.flip_h = false
	elif velocity.x < 0:
		animacao.flip_h = true

func pular():
	var pulin = Input.is_action_pressed("pulo")
	if pulin:
			velocity.y = JUMP_VELOCITY
			JUMP_VELOCITY += 30
	elif is_on_floor():
		JUMP_VELOCITY = -700.0
	else:
		return
