extends Node2D
class_name Global

signal purge(kind: ElementCube.Kind)

var kinds : Array[ElementCube.Kind] = []

var possible_colors = [
	Color.AQUA,
	Color.CORAL,
	Color.WEB_GREEN,
	Color.MEDIUM_VIOLET_RED,
	Color.BLACK,
	Color.BLUE_VIOLET,
	Color.TEAL,
	Color.BEIGE
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chosen_weights = []
	
	for c in possible_colors:
		var w = randi_range(1, 12)
		while (chosen_weights.find(w) != -1):
			w = randi_range(1, 12)
		
		chosen_weights.push_back(w)
		
		var kind = ElementCube.Kind.new()
		kind.color = c
		kind.weight = w
		kind.stability = randi_range(15, 30)
		
		kinds.push_back(kind)
	
	print("Initiated ", kinds.size(), " kinds")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
