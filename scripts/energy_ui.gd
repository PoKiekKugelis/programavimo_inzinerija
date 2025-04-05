extends Panel
class_name EnergyUI

@export var char_stats: CharStats : set = set_char_stats
@onready var energy_label: Label = $EnergyLabel

func set_char_stats(value: CharStats) -> void:
	char_stats = value
	if not char_stats.stats_changed.is_connected(on_stats_changed):
		char_stats.stats_changed.connect(on_stats_changed)
	if not is_node_ready():
		await ready
	on_stats_changed()

func on_stats_changed() -> void:
	energy_label.text = "%s/%s" % [char_stats.energy, char_stats.max_energy]
