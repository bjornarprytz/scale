extends Panel

var my_kind

func _ready() -> void:
	$Known/Button.button_down.connect(_click)

func _click():
	Autoload.purge.emit(my_kind)

func set_kind(kind: ElementCube.Kind):
	$Known/H/ColorRect.color = kind.color
	$Known/H/Known.text = "=" + str(kind.weight)
	my_kind = kind


