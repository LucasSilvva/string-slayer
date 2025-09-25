extends Node3D


@export var bar_game_tscn: PackedScene
var bars = []
var bars_node: Node3D
var bar_length_in_m: float = 8.0
var curr_location: Vector3 = Vector3(0,0,0)

@export var new_note_green_tscn: PackedScene
@export var new_note_red_tscn: PackedScene
@export var new_note_pink_tscn: PackedScene
@export var new_note_purple_tscn: PackedScene

@export var note_scale: float = 1.0
@export var power_manager: PowerManager
var next_note_to_spawn: int = 0
var time_passed: float = 0.0
var notes_data = [
	{ "pos": 0.0, "line": 1 },
	{ "pos": 1.0, "line": 2 },
	{ "pos": 2.5, "line": 1 },
	{ "pos": 3.0, "line": 3 },
	{ "pos": 4.5, "line": 4 },
	{ "pos": 5.0, "line": 2 },
	{ "pos": 6.5, "line": 1 },
	{ "pos": 7.0, "line": 3 },
	{ "pos": 8.0, "line": 4 },
	{ "pos": 9.5, "line": 2 },
	{ "pos": 10.0, "line": 1 },
	{ "pos": 11.5, "line": 4 },
	{ "pos": 12.0, "line": 3 },
	{ "pos": 13.5, "line": 2 },
	{ "pos": 14.0, "line": 1 },
	{ "pos": 15.5, "line": 4 },
	{ "pos": 16.0, "line": 2 },
	{ "pos": 17.5, "line": 3 },
	{ "pos": 18.0, "line": 1 },
	{ "pos": 19.5, "line": 4 },
	{ "pos": 20.0, "line": 2 },
	{ "pos": 21.5, "line": 3 },
	{ "pos": 22.0, "line": 1 },
	{ "pos": 23.5, "line": 4 },
	{ "pos": 24.0, "line": 2 },
	{ "pos": 25.5, "line": 1 },
	{ "pos": 26.0, "line": 3 },
	{ "pos": 27.5, "line": 4 },
	{ "pos": 28.0, "line": 2 },
	{ "pos": 29.5, "line": 1 },
	{ "pos": 30.0, "line": 4 },
	{ "pos": 31.5, "line": 3 },
	{ "pos": 32.0, "line": 2 },
	{ "pos": 33.5, "line": 1 },
	{ "pos": 34.0, "line": 4 },
	{ "pos": 35.5, "line": 2 },
	{ "pos": 36.0, "line": 3 },
	{ "pos": 37.5, "line": 1 },
	{ "pos": 38.0, "line": 4 },
	{ "pos": 39.5, "line": 2 },
	{ "pos": 40.0, "line": 3 },
	{ "pos": 41.5, "line": 1 },
	{ "pos": 42.0, "line": 4 },
	{ "pos": 43.5, "line": 2 },
	{ "pos": 44.0, "line": 1 },
	{ "pos": 45.5, "line": 3 },
	{ "pos": 46.0, "line": 4 },
	{ "pos": 47.5, "line": 2 },
	{ "pos": 48.0, "line": 1 },
	{ "pos": 49.5, "line": 4 },
]


var start_z_pos: float = 20.0
var end_z_pos: float = -10.0	
var note_speed: float = -2.0
var active_notes: Array[Node3D] = []



func _ready():

	power_manager = get_node("/root/game/PowerManager")
	print("Nota criada na posição Z:", self.global_position.z)
	randomize()

func spawn_next_note():
	var note_data = notes_data[next_note_to_spawn]
	var note: Node3D = null
	match note_data["line"]:
		1:
			note = new_note_green_tscn.instantiate()
		2:
			note = new_note_red_tscn.instantiate()
		3:
			note = new_note_pink_tscn.instantiate()
		4:
			note = new_note_purple_tscn.instantiate()
	if note:
		note.line = note_data["line"]
		note.position.z = start_z_pos
		note.set_note_position()
		add_child(note)
		active_notes.append(note)
		next_note_to_spawn += 1

func _process(delta):
	time_passed += delta
	if next_note_to_spawn < notes_data.size():
		if time_passed >= notes_data[next_note_to_spawn].pos:
			spawn_next_note()
	for i in range(active_notes.size() - 1, -1, -1):
		var note = active_notes[i]
		if is_instance_valid(note):
			note.position.z += note_speed * delta
			if note.position.z < end_z_pos and !note.is_collected:
				power_manager.on_note_missed()
				if power_manager.active_power != PowerManager.PowerType.COMBO_SHIELD or !power_manager.power_active:
					reset_combo()
				note.queue_free()
				active_notes.remove_at(i)


func add_bar():
	var bar = bar_game_tscn.instantiate()
	bar.position = Vector3(curr_location.x, curr_location.y, curr_location.z)
	bars.append(bar)
	bars_node.add_child(bar)
	curr_location +=Vector3(0,0,-bar_length_in_m)

func collect_note(note: Node3D):
	if active_notes.has(note):
		note.is_collected = true
		active_notes.erase(note)
		note.queue_free()
		power_manager.on_note_hit()
		var points = power_manager.calculate_score(100, combo, true)  # 100 é base_points
		add_score(points)
			
var score: int = 0
var combo: int = 0

func add_score(points: int):
		combo += 1
		@warning_ignore("integer_division")
		var combo_multiplier = min(int(combo / 10) + 1, 4)
		var score_to_add = points * combo_multiplier
		score += score_to_add
		print("Pontuação:", score, " | Combo:", combo, " | Multiplicador:", combo_multiplier)


func reset_combo():
	combo = 0
	print("Combo quebrado! Combo:", combo)
