extends CharacterBody2D

# Variables for movement
@export var speed = 200.0
@export var jump_force = 400.0
@export var dash_speed = 600.0
@export var dash_duration = 0.2

# Internal state variables
var velocity = Vector2.ZERO
var is_jumping = false
var is_dashing = false
var dash_time_left = 0.0

func _get_input():
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1

	input_vector = input_vector.normalized()

	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		is_jumping = true

	if Input.is_action_just_pressed("ui_dash") and not is_dashing:
		is_dashing = true
		dash_time_left = dash_duration

	return input_vector

func _physics_process(delta):
	var input_vector = _get_input()

	if is_dashing:
		velocity.x = dash_speed * (input_vector.x if input_vector.x != 0 else direction)
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false
	else:
		velocity.x = input_vector.x * speed

	if is_jumping:
		velocity.y = -jump_force
		is_jumping = false

	if not is_on_floor():
		velocity.y += 400 * delta  # Gravity

	velocity = move_and_slide(velocity, Vector2.UP)

# Signals for better debugging
func _on_jump():
	print("Player jumped")

func _on_dash():
	print("Player dashed")
