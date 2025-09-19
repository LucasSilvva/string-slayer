extends Node3D

@export_range(1,4) var line: int
var parent_road: Node
var is_collected: bool = false

func _ready():
	var note_picker = find_child("NotePicker", true)
	if note_picker:
		note_picker.parent_road = parent_road
	
func _process(delta) -> void:
	pass

func set_note_position():
		var x: float
		match line:
			1:
				x =2.2
			2:
				x = -0.15
			3:
				x = -2.50
			4:
				x = -4.90
		self.position.x = x
