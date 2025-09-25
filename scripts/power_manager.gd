extends Node3D

class_name PowerManager
enum PowerType { NONE, COMBO_SHIELD, OVERDRIVE, FRENZY, CHAIN_MASTER }

@export var active_power: PowerType = PowerType.OVERDRIVE
var power_meter: float = 0.0            # 0.0 a 1.0
var power_fill_per_note: float = 0.05   # quanto cada nota adiciona
var power_active: bool = false
var power_duration: float = 5.0
var power_timer: float = 0.0

# Chain Master
var penalty_mode: bool = false
var penalty_counter: int = 0
const CHAIN_MASTER_PENALTY_NOTES: int = 100

# Combo Shield
var missed_notes: int = 0   # conta notas que passaram sem gerar score

# ---------------- Debug / Test ----------------

# Retorna se o poder está pronto para ativar
func is_power_available() -> bool:
	return power_meter >= 1.0 and !power_active

# Teste rápido: enche o medidor para o poder atual
func fill_power_meter():
	power_meter = 1.0
	print("DEBUG: Medidor do poder cheio! ", str(active_power))

# ---------------- Métodos públicos ----------------

func on_note_hit():
	if !power_active:
		power_meter = clamp(power_meter + power_fill_per_note, 0.0, 1.0)

	# Chain Master: contar notas no modo penalidade
		print("Power Meter Atual: ", power_meter) 
	if active_power == PowerType.CHAIN_MASTER and penalty_mode:
		penalty_counter += 1
		if penalty_counter >= CHAIN_MASTER_PENALTY_NOTES:
			penalty_mode = false
			penalty_counter = 0

func on_note_missed():
	if active_power == PowerType.CHAIN_MASTER:
		penalty_mode = true
		penalty_counter = 0
	elif active_power == PowerType.COMBO_SHIELD:
		missed_notes += 1

func calculate_score(base_points: int, combo: int, note_hit: bool = true) -> int:
	var points = base_points
	if active_power == PowerType.COMBO_SHIELD and missed_notes > 0 and !note_hit:
		points = 0
	if active_power == PowerType.OVERDRIVE and power_active:
			if combo % 10 == 0:
				points *= 2

	if active_power == PowerType.FRENZY and power_active:
		points = int(points * 1.5)

	if active_power == PowerType.CHAIN_MASTER and penalty_mode:
		points = int(points * 1)

	return points

# ---------------- Input / Ativação ----------------

func _input(event):
	if event.is_action_pressed("power_activate") and is_power_available():
		activate_power()

# Ativar poder
func activate_power():
	power_active = true
	power_meter = 0.0
	power_timer = power_duration
	if active_power == PowerType.COMBO_SHIELD:
		missed_notes = 0
	print("DEBUG: Poder ativado -> ", str(active_power))

# Timer do poder e debug de disponibilidade
func _process(delta):
	if power_active:
		power_timer -= delta
		if power_timer <= 0:
			power_active = false
			print("DEBUG: Poder acabou -> ", str(active_power))
	else:
		if power_meter >= 1.0:
			print("DEBUG: Poder disponível -> ", str(active_power))
	
