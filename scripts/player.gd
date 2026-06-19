extends CharacterBody2D
@onready var animacao: AnimatedSprite2D = $animaçao


var SPEED = 30000.0
var JUMP_VELOCITY = -800.0
var velocidade_queda = Vector2(0, 75)
var altura_inicio = 0
var estado = 0 # 0 - Parado; 1 - Subindo; 2 - Caindo;
var pulo_tempo = 0
var pulo_max = 0.35


func _physics_process(delta: float) -> void:
#Gravidade
	# Movimentar
	mover(delta)
	
	# Pular ao estar no chão
	if estado == 0 and Input.is_action_pressed("pulo"):
		estado = 2
		altura_inicio = position.y
	# Manipulador de estados no ar
	if not is_on_floor():
		if estado == 0 and estado != 1:
			estado = 1
	elif estado != 2:
		estado = 0
		
	# Estados no ar
	match estado:
		1:
			velocity += velocidade_queda
			animacao.play("caindo")
		2:
			pular(delta)
			animacao.play("pulando")

	move_and_slide()

func mover(delta):

	# Vai para os lados
	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = 0

	if velocity.x == 0:
		animacao.play("parado")
	elif velocity.x != 0:
		animacao.play("andando")

	# Ajusta a animação para o lado correto
	if velocity.x > 0:
		animacao.flip_h = false
	elif velocity.x < 0:
		animacao.flip_h = true

func pular2():
	var pulin = Input.is_action_pressed("pulo")
	if pulin:
			velocity.y = JUMP_VELOCITY
			JUMP_VELOCITY += 30
	elif is_on_floor():
		JUMP_VELOCITY = -700.0
	else:
		return

func pular(delta):
	if not is_on_ceiling() and Input.is_action_pressed("pulo") and not pulo_tempo >= pulo_max:
		pulo_tempo += delta
		velocity.y = JUMP_VELOCITY
	else:
		velocity.y = JUMP_VELOCITY * ((1/pulo_max) * pulo_tempo)
		estado = 1
		
		pulo_tempo = 0
	pass
