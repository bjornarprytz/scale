extends RigidBody2D
class_name ElementCube

class Kind:
	var color : Color
	var weight : int

@export var damageMultiplier = 0.1  # You can adjust this value to control the damage

var kind : Kind:
	set(value):
		kind = value
		modulate = kind.color

@onready var boom : CPUParticles2D = $Explosion
var held : bool
var hovered : bool

func _physics_process(delta: float) -> void:
	if (!held):
		return
	
	global_position = get_global_mouse_position()

func _on_RigidBody2D_body_entered(body: Node):
	if body is RigidBody2D or body is StaticBody2D:
		# Get the collision energy
		var collision_energy = get_collision_energy()

		# Calculate damage based on collision energy
		var damage = collision_energy * damageMultiplier

		# Call a function to apply the damage to the object
		apply_damage(damage)

func explode():
	$Color.visible = false
	boom.emitting = true
	
	await get_tree().create_timer(boom.lifetime).timeout
	
	queue_free()

func apply_damage(amount):
	# Implement your damage logic here
	# You can decrease health, play a sound, spawn particle effects, etc.
	
	if (amount > 30):
		print("Total damage:", amount)
		explode()


func get_collision_energy() -> float:
	var impulse = linear_velocity * mass
	
	return impulse.length()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		held = hovered and event.is_pressed()
		
		if (held):
			freeze = true
		else:
			freeze = false

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
