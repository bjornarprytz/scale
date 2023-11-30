extends AudioStreamPlayer

func _ready() -> void:
	finished.connect(play)
