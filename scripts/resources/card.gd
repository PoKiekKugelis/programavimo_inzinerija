extends Resource
class_name Card

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_group("Card Attritubes")
@export var id: String
@export var type: Type
@export var target: Target
@export var cost: int

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
		
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("Player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemy")
		Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemy")
		_:
			return []

func play(targets: Array[Node], char_stats: CharStats, scene_context: Node) -> void:
	Events.card_played.emit(self)
	char_stats.energy -= cost

	if is_single_targeted():
		apply_effects(targets, scene_context)
	else:
		apply_effects(get_targets(targets), scene_context)

func apply_effects(_targets: Array[Node], _scene_context: Node) -> void:
	pass
