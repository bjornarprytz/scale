class_name Replicator
extends Node2D

signal replicate(kind: ElementCube.Kind)

const REPLICATE_DURATION = 7.0

@onready var red : PointLight2D = $RedSpectralCombobulator
@onready var green : PointLight2D = $GreenSprectralCombobulator
@onready var blue : PointLight2D = $BlueSprectralCombobulator
@onready var atoms : CPUParticles2D = $StrayAtoms

@onready var sensor : Area2D = $ContentsDetector

const interval := 1.5
var time_left = 0.0

var candidates: Array[ElementCube] = []

var replicating : bool

var light_tween : Tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time_left = max(0.0, time_left - delta)
	
	if (time_left <= 0.0 and replicating):
		replicate.emit(candidates.pick_random().kind)
		time_left = randf_range(1.0, 2.0)

func _light_function(f: float):
	var factor = f * 32.0
	red.energy = pingpong(factor, 0.5)
	green.energy = pingpong(factor, 0.8)
	blue.energy = pingpong(factor, 0.9)

func _on_contents_detector_body_entered(body: Node2D) -> void:
	var was_replicating = replicating
	if (body is ElementCube and not candidates.has(body)):
		candidates.push_back(body)
	
	replicating = candidates.size() > 0
	
	if (!was_replicating and replicating):
		_start_replicating()

func _on_contents_detector_body_exited(body: Node2D) -> void:
	if (body is ElementCube):
		candidates.erase(body)
	
	replicating = candidates.size() > 0
	
	if (!replicating):
		_stop_replicating()

func _start_replicating():
	light_tween = create_tween()
	light_tween.tween_method(_light_function, 0.0, 1.0, REPLICATE_DURATION)
	light_tween.tween_callback(_stop_replicating)
	red.enabled = true
	green.enabled = true
	blue.enabled = true
	atoms.emitting = true
	$Hum.play()

func _stop_replicating():
	light_tween.kill()
	red.enabled = false
	green.enabled = false
	blue.enabled = false
	atoms.emitting = false
	for cube in candidates:
		cube.explode()
	
	candidates.clear()
	
	$Hum.stop()
