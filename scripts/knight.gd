extends CharacterBody2D

@export var move_speed: float = 256.0 # velocidade de movimento
@export var damage: int = 1 # dano causado pelo personagem
@export var health: int = 10 # vida do personagem

@onready var animation: AnimationPlayer = get_node("Animation") 
@onready var aux_animation: AnimationPlayer = get_node("AuxAnimation")
@onready var texture: Sprite2D = get_node("Texture")
@onready var attack_area: CollisionShape2D = get_node("AttackArea/Collision")

var can_attack: bool = true # flag que define se o personagem pode ou nao atacar
var can_die: bool = false # flag que define se o personagem esta morto ou nao

func _physics_process(_delta: float) -> void: # funcao de update de fisica
	if (
		can_attack == false or # personagem fica parado ao executar um ataque
		can_die # personagem esta morto
	): 
		return
		
	move()
	animate()
	attack_handler()
	

func move() -> void:
	var direction : Vector2 = get_direction() # direcao do personagem
	velocity = direction * move_speed # velocidade personagem
	move_and_slide() # funcao de movimentacao com colisao


func get_direction() -> Vector2: # retorna a direcao pressionada no teclado
	return Vector2 (
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
			).normalized()


func animate() -> void: # lida com as animações
	if velocity.x < 0: # personagem andando para esquerda
		texture.flip_h = true # flipa o personagem para a esquerda
		attack_area.position.x = -58 # posiçao da area de ataque esquerda
		
	elif velocity.x > 0: # personagem andando para direita
		texture.flip_h = false # flipa o personagem para a direita
		attack_area.position.x = 58 # posiçao da area de ataque direita
		
	if velocity != Vector2.ZERO: # Significa que o personagem esta se movendo
		animation.play("run") # roda animação de run (correr)
		return
		
	animation.play("idle") # roda a animação de idle (parado)


func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") and can_attack: # se pressionada ação de atacar e puder atacar
		can_attack = false # flag é configurada para false evitando bugs de congelar a animação
		animation.play("attack") # roda animação de ataque


# sinal emitido quando alguma animação termina
func on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack": # quando termina a animação de ataque o personagem pode atacar novamente
			can_attack = true
			
		"death":
			get_tree().reload_current_scene() # quando a animacao de morte terminar, reinicia a cena atual 


# sinal que monitora quando algum objeto fisico entra em contato com a area de ataque
func on_attack_area_body_entered(body) -> void: 
	body.update_health(damage) # envia para funcao de atualizar o dano causado pelo body
	

# funcao que atualiza a vida do personagem
func update_health(value: int) -> void: # VALUE é o valor recebido da funcao "on_attack_area_body_entered"
	health -= value # diminui a vida pelo valor recebido
	if health <= 0: # vida do personagem chega a zero
		can_die = true # flag é configurada para true
		animation.play("death") # roda a animação de morte
		attack_area.set_deferred("disabled", true) # desabilita a colisao da area de ataque
		return
	
	aux_animation.play("hit") # toma hit mas nao morre roda a animação de hit
