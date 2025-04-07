extends Label

func _ready() -> void:
	$".".text = str(Money.get_money())
	Money.money_changed.connect(change_label)
	
func change_label(money: int):
	$".".text = str(money);
