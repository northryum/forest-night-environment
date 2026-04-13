extends CharacterBody3D
# Trocar entre 1ª e 3ª pessoa com uma tecla
var primeira_pessoa = true

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.003

@onready var spring_arm = $SpringArm3D
@onready var mesh = $MeshInstance3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Trava o mouse na tela
	# mesh.visible = false # Esconde a cápsula pra não atrapalhar a visão


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS) # Gira o player pros lados
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENS) # Gira a câmera pra cima/baixo
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/4) # Limita pra não dar cambalhota

	# Trocar entre 1ª e 3ª pessoa
	if event.is_action_pressed("change_camera"): # Tecla C
		print("Mudou câmera")
		primeira_pessoa = !primeira_pessoa
		if primeira_pessoa:
			spring_arm.spring_length = 0
			mesh.visible = false
		else:
			spring_arm.spring_length = 4
			mesh.visible = true
	



	if event.is_action_pressed("ui_cancel"): # Aperta ESC pra soltar o mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	#region Movimento e Gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#endregion
