extends Node2D

const MAX_SCORE := 69000
var SPAWN_TIME := 2.0

@onready var cube_spawner = preload("res://things/cube.tscn")
@onready var answer_spawner = preload("res://things/answer.tscn")
@onready var known_spawner = preload("res://things/known.tscn")

@onready var spawn_point : Node2D = $SpawnPoint
@onready var info : GridContainer = $CanvasLayer/Control/AnswerGrid

var won : bool
var t := 100.0
var elapsed := 0.0

func _ready() -> void:
	Autoload.purge.connect(_purge)
	Autoload.game_over.connect(_game_over)
	
	var known_info = Autoload.kinds.pick_random()
	Autoload.submit_answer(known_info, known_info.weight)
	
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

func _game_over(win: bool):
	won = win
	
	if (win):
		SPAWN_TIME = 0.5
		$CanvasLayer/WinText.visible = true
		$CanvasLayer/Score.visible = true
		$CanvasLayer/Score.add_text(str(_score_formula()))

func _process(delta: float) -> void:
	t += delta
	elapsed += delta
	
	if (t > SPAWN_TIME):
		t = 0.0
		if ($Cubes.get_child_count() < 20):
			var cube = cube_spawner.instantiate() as ElementCube
			cube.kind = Autoload.kinds.pick_random()
			
			$Cubes.add_child(cube)
			cube.position = spawn_point.position
		
		if (won):
			for c in $Cubes.get_children():
				c.apply_force(Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 0.0)) * randf_range(30000.0, 50000.0))
		

func _score_formula() -> int:
	return (MAX_SCORE - (elapsed * 10.0) - (Autoload.exploded_cubes * 1000.0)) / (Autoload.wrong_answers +1)
