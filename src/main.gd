extends Node2D

const SPAWN_TIME := 2.0

@onready var cube_spawner = preload("res://things/cube.tscn")
@onready var answer_spawner = preload("res://things/answer.tscn")
@onready var known_spawner = preload("res://things/known.tscn")

@onready var spawn_point : Node2D = $SpawnPoint
@onready var info : GridContainer = $CanvasLayer/Control/AnswerGrid

var t := 100.0
var elapsed := 0.0

func _ready() -> void:
	Autoload.purge.connect(_purge)
	
	var known_info = Autoload.kinds.pick_random()
	
	var kn = known_spawner.instantiate()
	kn.set_kind(known_info)
	
	info.add_child(kn)
	
	for k in Autoload.kinds:
		if (k == known_info):
			continue
		
		var an = answer_spawner.instantiate()
		an.set_kind(k)
		
		info.add_child(an)

func _purge(kind: ElementCube.Kind):
	for c in $Cubes.get_children():
		if c.kind == kind:
			c.explode()

func _process(delta: float) -> void:
	t += delta
	
	if (t > SPAWN_TIME and $Cubes.get_child_count() < 20):
		t = 0.0
		
		var cube = cube_spawner.instantiate() as ElementCube
		cube.kind = Autoload.kinds.pick_random()
		
		$Cubes.add_child(cube)
		cube.position = spawn_point.position
	
