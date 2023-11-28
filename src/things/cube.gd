extends RigidBody2D
class_name ElementCube

class Kind:
	var color : Color
	var weight : int
	var stability : int

@export var damageMultiplier = 0.1  # You can adjust this value to control the damage

var kind : Kind:
	set(value):
		kind = value
		modulate = kind.color

@onready var boom : CPUParticles2D = $Explosion
@onready var shape : CollisionShape2D = $Shape

var prev_pos : Vector2
var momentum : Vector2
var held : bool
var hovered : bool

func _physics_process(delta: float) -> void:
	if (!held):
		return
	
	if (prev_pos != Vector2.ZERO):
		momentum = (global_position - prev_pos) * 50000.0 * delta
	prev_pos = global_position
	global_position = get_global_mouse_position()

func _on_RigidBody2D_body_entered(body: Node):
	if body is RigidBody2D or body is StaticBody2D:
		var damage = get_collision_energy() * damageMultiplier

		apply_damage(damage)

func explode():
	$Color.visible = false
	set_deferred("freeze", true)
	shape.set_deferred("disabled", true)
	
	boom.emitting = true
	Autoload.exploded_cubes += 1
	
	await get_tree().create_timer(boom.lifetime).timeout
	
	queue_free()

func apply_damage(amount):
	if (amount > 30):
		explode()


func get_collision_energy() -> float:
	var impulse = linear_velocity * mass
	
	return impulse.length()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var was_held = held
		held = hovered and event.is_pressed()
		
		if (held):
			freeze = true
		else:
			freeze = false
			if was_held:
				apply_force(momentum) # Throw

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
