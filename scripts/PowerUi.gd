extends CanvasLayer


@export var power_manager_node: NodePath

var power_manager

var powers = ["OVERDRIVE", "COMBO_SHIELD", "FRENZY", "CHAIN_MASTER"]
var power_bars = {}

func _ready():
	power_manager = get_node(power_manager_node)
	if power_manager == null:
		push_error("PowerManager não encontrado! Caminho: " + str(power_manager_node))
	for p in powers:
		var rect = $HBoxContainer.get_node(p)
		power_bars[p] = rect
		rect.color = Color.GRAY  

func _process(delta):
	for p in powers:
		var power_type = PowerManager.PowerType[p]
		var rect = power_bars[p]
		if power_manager.active_power == power_type:
			if power_manager.power_active:
				rect.color = Color(0.2, 0.6, 1)  # azul
				rect.custom_minimum_size.x = int(200 * (power_manager.power_timer / power_manager.power_duration))# cheio horizontalmente durante ativo
			else:
					rect.color = Color.GRAY
					rect.custom_minimum_size.x = int(200 * power_manager.power_meter)
					if power_manager.is_power_available():
							rect.color = Color(0.8, 0.8, 0.1)
						
		else:
			rect.color = Color.GRAY
			rect.size.x = int(200 * 0)  # vazio
