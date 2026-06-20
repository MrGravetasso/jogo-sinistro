extends CharacterBody2D
@onready var animacao: AnimatedSprite2D = $animaçao

# Forças
var SPEED = 800.0
var velocidade_queda = 2200
# Pulo Normal
var pulo_forca = -800.0
var estado = 0 # 0 - Parado; 1 - Subindo; 2 - Caindo;
var pulo_tempo = 0
var pulo_max = 0.35
# Pulo do Coiote
var coiote = 0.0
const COIOTE_TEMPO = 0.1

func _physics_process(delta: float) -> void:
	# Movimentar
	mover()
	
	## PULO
	# Resetar ou decrementar o tempo do coiote
	if estado != 0:
		coiote -= delta
	else:
		coiote = COIOTE_TEMPO
	# Pular ao estar no chão
	if coiote > 0 and Input.is_action_pressed("pulo"):
		estado = 2
		coiote = 0
		
	# Manipulador de estados no ar
	if not is_on_floor():
		if estado == 0 and estado != 1:
			estado = 1
	elif estado != 2:
		estado = 0
	# Estados no ar
	match estado:
		1:
			velocity.y += velocidade_queda * delta
			animacao.play("caindo")
		2:
			pular(delta)
			animacao.play("pulando")

	move_and_slide()

## Função para a movimentação lateral do jogador
func mover() -> void:
	# Vai para os lados
	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED 
	else:
		velocity.x = 0
	
	# Ativa a animação do jogador conforme as condições
	if velocity.x == 0:
		animacao.play("parado")
	elif velocity.x != 0:
		animacao.play("andando")

	# Ajusta a animação para o lado correto
	if velocity.x > 0:
		animacao.flip_h = false
	elif velocity.x < 0:
		animacao.flip_h = true

# INFO código não utilizado
#func pular2():
	#var pulin = Input.is_action_pressed("pulo")
	#if pulin:
			#velocity.y = pulo_forca
			#pulo_forca += 30
	#elif is_on_floor():
		#pulo_forca = -700.0
	#else:
		#return

## Função para o jogador pular
func pular(delta) -> void: 

	if not is_on_ceiling() and Input.is_action_pressed("pulo") and not pulo_tempo >= pulo_max:
		pulo_tempo += delta
		velocity.y = pulo_forca
	else:
		velocity.y = pulo_forca * ((1/pulo_max) * pulo_tempo)
		estado = 1
		
		pulo_tempo = 0
	pass
