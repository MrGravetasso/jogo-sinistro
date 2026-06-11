extends CharacterBody2D

enum PlayerState {
	parado,
	andando,
	pulando,
	deitado,
	caindo,
	deslizando,
	morreu,
	queimando,
	nadando,
	segurando
	}

const CAMERA = preload("uid://c076p2o6nd55g")
@onready var sla: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisão: CollisionShape2D = $CollisionShape2D
@onready var hitbox: CollisionShape2D = $hitbox/hit
@onready var parede_direita: RayCast2D = $"parede direita"
@onready var parede_esquerda: RayCast2D = $"parede esquerda"
@onready var timer: Timer = $Timer
@onready var timer_morte: Timer = $Timer_morte

@export var JUMP_VELOCITY = -300.0
@export var RETORNO_PAREDE = 300.0
@export var V_MAX = 120.0
@export var ACELERAÇÃO_ANDAR = 1200
@export var DESACELERAÇÃO_ANDAR = 8
@export var MAX_PULOS = 1
@export var PODE_DESLIZAR = 1
@export var DESACELERAÇÃO_DEITADO = 50
@export var ACELERAÇÃO_ÁGUA = 150
@export var DESACELERAÇÃO_ÁGUA = 200
@export var V_MAX_ÁGUA = 80
@export var FORÇA_NADO = -100

var camera = CAMERA.instantiate()
var status: PlayerState
var direction = 0
var paredão = 1
var pulos = 0
var player_morto = false
var gravit = true

func _ready() -> void:
	preparar_parado()

func mover(delta):
	lados()

	if direction:
		velocity.x = move_toward(velocity.x, direction * V_MAX, ACELERAÇÃO_ANDAR * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DESACELERAÇÃO_ANDAR)

func lados():
	direction = Input.get_axis("esquerda", "direita")

	if direction > 0:
		sla.flip_h = false
	elif direction < 0:
		sla.flip_h = true

func gravidade(delta):
	if not is_on_floor() and gravit == true:
		velocity += get_gravity() * delta

func _physics_process(delta: float) -> void:
	gravidade(delta)

	match status:
		PlayerState.parado:
			parado_state(delta)
		PlayerState.andando:
			andando_state(delta)
		PlayerState.pulando:
			pulando_state(delta)
		PlayerState.deitado:
			deitado_state(delta)
		PlayerState.caindo:
			caindo_state(delta)
		PlayerState.deslizando:
			deslizando_state(delta)
		PlayerState.morreu:
			morrendo_state(delta)
		PlayerState.queimando:
			queimando_state(delta)
		PlayerState.segurando:
			segurando_state(delta)
		PlayerState.nadando:
			nadando_state(delta)

	move_and_slide()

func preparar_parado():
	status = PlayerState.parado
	sla.play("parado")

func preparar_andar():
	status = PlayerState.andando
	sla.play("andar")

func preparar_deitado():
	status = PlayerState.deitado
	sla.play("deitado")
	ir_deitar()

func preparar_cair():
	status = PlayerState.caindo
	sla.play("caindo")

func preparar_morrer():
	if status == PlayerState.morreu:
		return

	status = PlayerState.morreu
	sla.play("morreu")
	voltar_do_deitar()

	gravit = false
	player_morto = true
	velocity.x = 0
	hitbox.queue_free()
	collision_layer = 0
	collision_mask = 0

	var ponto_da_morte = global_position + Vector2.UP * 120
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"global_position",ponto_da_morte,0.3)
	timer_morte.start()

func preparar_pular():
	status = PlayerState.pulando
	sla.play("pulo")
	velocity.y = JUMP_VELOCITY
	pulos += 1

func preparar_segurar():
	status = PlayerState.segurando
	sla.play("segurando")
	velocity = Vector2.ZERO

	gravit = false

func preparar_deslizando():
	if PODE_DESLIZAR == 1:
		status = PlayerState.deslizando
		sla.play("deitado")
		ir_deitar()
	else:
		status = PlayerState.andando

func preparar_queima():
	if status == PlayerState.queimando:
		return

	status = PlayerState.queimando
	sla.play("queimar")
	gravit = false
	velocity.y = 30
	velocity.x = 0
	timer.start()

func voltar_do_deitar():
	colisão.shape.size.x = 7.519
	colisão.shape.size.y = 19.945
	colisão.position.x = -50.0
	colisão.position.y = 0.0

	hitbox.shape.size.x = 11.0
	hitbox.shape.size.y = 26.0
	hitbox.position.x = -50.0
	hitbox.position.y = 0.0

func ir_deitar():
	colisão.shape.size.x = 19.823
	colisão.shape.size.y = 6.904
	colisão.position.x = -50.0
	colisão.position.y = 8.5

	hitbox.shape.size.x = 30.0
	hitbox.shape.size.y = 9.0
	hitbox.position.x = -50.0
	hitbox.position.y = 8.5

func preparar_nadar():
	status = PlayerState.nadando
	sla.play("deitado")
	velocity.y /= 2.5
	gravit = false
	ir_deitar()

func parado_state(delta):
	mover(delta)
	if !is_on_floor():
		preparar_cair()
		return
	if Input.is_action_pressed("pulin") and is_on_floor():
		preparar_pular()
		return
	if Input.is_action_pressed("deitar") and is_on_floor():
		preparar_deitado()
		return
	if velocity.x != 0:
		preparar_andar()
		return

func andando_state(delta):
	mover(delta)
	if velocity.x == 0:
		preparar_parado()
		return
	if Input.is_action_pressed("pulin") and is_on_floor():
		preparar_pular()
		return
	if Input.is_action_pressed("deitar") and is_on_floor():
		preparar_deslizando()
		return
	if !is_on_floor():
		preparar_cair()
		return

func deitado_state(_delta):
	lados()
	if Input.is_action_pressed("pulin") and is_on_floor():
		voltar_do_deitar()
		preparar_parado()
		return

func queimando_state(_delta):
	pass

func segurando_state(delta):
	velocity.y += 15 * 15 * delta

	if !parede_direita.is_colliding() and !parede_esquerda.is_colliding():
		gravit = true
		preparar_cair()
		return

	if is_on_floor():
		preparar_parado()
		gravit = true
		return

	if sla.flip_h == true:
		direction = 1
	else:
		direction = -1

	if Input.is_action_pressed("pulin"):
		velocity.x = RETORNO_PAREDE * direction
		velocity.y = -300
		preparar_pular()
		gravit = true
		return

func morrendo_state(_delta):
	pass

func caindo_state(delta):
	mover(delta)

	if Input.is_action_just_pressed("pulin") and pode_pular():
		preparar_pular()
		return

	if is_on_floor():
		pulos = 0
		if velocity.x != 0:
			preparar_andar()
		if velocity.x == 0:
			preparar_parado()
		return

	if (parede_direita.is_colliding()) and is_on_wall():
		sla.flip_h = false
		preparar_segurar()
		return
	if (parede_esquerda.is_colliding()) and is_on_wall():
		sla.flip_h = true
		preparar_segurar()
		return

func nadando_state(delta):
	lados()

	if direction:
		velocity.x = move_toward(velocity.x, direction * V_MAX_ÁGUA, ACELERAÇÃO_ÁGUA * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DESACELERAÇÃO_ÁGUA * delta)

	velocity.y += ACELERAÇÃO_ÁGUA * delta
	velocity.y = min(velocity.y,V_MAX_ÁGUA)

	if Input.is_action_just_pressed("pulin"):
		velocity.y = FORÇA_NADO

func pulando_state(delta):
	mover(delta)

	if Input.is_action_just_pressed("pulin") and pode_pular():
		preparar_pular()
		return

	if velocity.y > 0:
		preparar_cair()
		return

func deslizando_state(delta):
	velocity.x = move_toward(velocity.x, 0,DESACELERAÇÃO_DEITADO * delta)

	if velocity.x == 0:
		voltar_do_deitar()
		preparar_deitado()
		return

func pode_pular() -> bool:
	return MAX_PULOS > pulos

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("inimigo"):
		inimigo(area)
	if area.is_in_group("bagui q da dano"):
		coisa_que_machuca()

func inimigo(area: Area2D):
	if velocity.y > 0:
		area.get_parent().matar()
		preparar_pular()
	else:
		preparar_morrer()

func coisa_que_machuca():
		preparar_morrer()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("bagui q da dano"):
		preparar_queima()
		return
	elif body.is_in_group("nadar"):
		preparar_nadar()
		return
	else:
		return

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("nadar"):
		preparar_pular()
		voltar_do_deitar()
		gravit = true
		return
	else:
		return

func _on_timer_morte_timeout() -> void:
	var teem = create_tween()
	var ponto_da_queda = global_position + Vector2.DOWN * 250
	teem.set_trans(Tween.TRANS_QUAD)
	teem.set_ease(Tween.EASE_IN)
	teem.tween_property(self,"global_position",ponto_da_queda,0.6)
	timer.start()
