extends CharacterBody2D

@export var move_speed : float = 120
#@export var run_speed : float = 180
@export var jump_speed : float = 300
@export var can_dash : bool = true # Variable para controlar si se puede hacer dash
@export var dash_action : bool = false # Variable para detectar si se esta haciendo dash
@export var dash_speed : float = 300 # Variable para controlar la velocidad del dash
var last_direction = Vector2.RIGHT # Variable para almacenar la última dirección	
@onready var animacion = $AnimatedSprite2D
@onready var dashDuration = $dashDuration
@onready var dashCooldown = $dashCooldown
@onready var dashAnim = $GPUParticles2D
var facing_right = true
var strong_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Estados del personaje
enum State {
	IDLE,
	MOVING,
	RUNNING,
	DASHING,
	JUMPING,
	FALLING,
	MAX_JUMP
}

var current_state = State.IDLE

func _physics_process(delta):
	gravity(delta)
	move_x(delta)
	dash()
	jump()
	flip()
	move_and_slide()
	update_state(delta)

func gravity(delta):
	velocity.y += strong_gravity * delta

func move_x(delta):
	var input_axis = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if dash_action:
		velocity.x = last_direction.x * dash_speed
	else:
		velocity.x = input_axis * move_speed
		if input_axis != 0:
			last_direction = Vector2(input_axis, 0).normalized() # Actualiza la última dirección cuando se mueve
	
	# Esta condicional es para permitir que el personaje corra
	#if Input.is_action_pressed("run"):
		#if is_on_floor():
			#velocity.x = input_axis * run_speed
	#else:
		#velocity.x = input_axis * move_speed

func jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed

func dash():
	if can_dash and Input.is_action_just_pressed("dash"):
		if facing_right:
			dashAnim.texture.load_path = "res://.godot/imported/player dash.png-c99a3d8402b1b13de7701e18d87903ae.ctex"
		else:
			dashAnim.texture.load_path = "res://.godot/imported/player dash left.png-4bcb46eae3f4f6f1c22b48aef8867fed.ctex"
		dash_action = true
		can_dash = false
		dashDuration.start()

func _on_dash_duration_timeout():
	dash_action = false
	dashCooldown.start()

func _on_dash_cooldown_timeout():
	can_dash = true

func flip():
	if (facing_right and velocity.x < 0) or (not facing_right and velocity.x > 0):
		scale.x *= -1
		facing_right = not facing_right

func update_state(delta):
	if is_on_floor():
		if velocity.x == 0:
			change_state(State.IDLE)
		else:
			if dash_action:
				change_state(State.DASHING)
			else:
				change_state(State.MOVING)
				
			# Esta condicinal es para cambiar el estado a correr
			#if Input.is_action_pressed("run"):
				#change_state(State.RUNNING)
			#else:
				#change_state(State.MOVING)
	else:
		if velocity.y < 0:
			if dash_action:
				change_state(State.DASHING)
			else:
				if velocity.y == -jump_speed:
					if dash_action:
						change_state(State.DASHING)
					else:
						change_state(State.JUMPING)
				else:
					if dash_action:
						change_state(State.DASHING)
					else:
						change_state(State.MAX_JUMP)
		else:
			change_state(State.FALLING)

func change_state(new_state):
	if current_state != new_state:
		current_state = new_state
		match current_state:
			State.IDLE:
				print("Personaje está quieto")
				animacion.play("Idle")
			State.MOVING:
				print("Personaje en movimiento")
				animacion.play("Run")
			State.DASHING:
				print("Personaje dasheando")
				animacion.play("Dash")
				dashAnim.emitting = true
			State.RUNNING:
				print("Personaje corriendo")
				animacion.play("Run")
			State.JUMPING:
				print("Personaje saltando")
				animacion.play("Jump")
			State.MAX_JUMP:
				print("Personaje en altura máxima del salto")
				animacion.play("Peak")
			State.FALLING:
				print("Personaje cayendo")
				animacion.play("Fall")
