extends Node3D

@export_range(1,4) var line: int

var my_material: StandardMaterial3D
var my_mesh: MeshInstance3D
var is_collecting = false
var parent_road: Node


func _find_mesh_instance(node):
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found_mesh = _find_mesh_instance(child)
		if found_mesh:
			return found_mesh
	return null
var my_area_3d: Area3D
var note_to_collect: Node3D = null
func _ready():
	my_mesh = _find_mesh_instance(self)   
	if not my_mesh:
		print("Error")
		return
		
	my_area_3d = find_child("Area3D", true)
	if not my_area_3d:
		print("Erro: Area3D não encontrado!")
	parent_road = get_parent()

func _input(event):
	var action_name = "line_" + str(line)
	if event.is_action_pressed(action_name):
		print("Ação Pressionada:", action_name)
		self.scale = Vector3(0.9, 0.9, 0.9)
		if is_instance_valid(note_to_collect):
			print("NOTA PRONTA PARA COLETAR!")
			if parent_road != null:
				parent_road.collect_note(note_to_collect)
				get_parent().add_score(100)
			note_to_collect= null
		else:
			print("NOTA NÃO ENCONTRADA. COMBO RESETADO.")
			get_parent().reset_combo()
	if event.is_action_released(action_name):
		self.scale = Vector3(1, 1, 1)



func _on_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("note"):
		if is_instance_valid(note_to_collect) and area.get_parent() == note_to_collect:
			get_parent().reset_combo()
			note_to_collect= null

var is_colliding_with_note: bool = false
var note_in_picker: Node3D

func _on_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("note"):
		note_to_collect = area.get_parent()
