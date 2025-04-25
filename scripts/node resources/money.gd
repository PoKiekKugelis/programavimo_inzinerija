extends Node

#pradinis kiekis
@onready var money = 30
signal money_changed

func add_money(amount: int):
	money += amount
	money_changed.emit(money)

func subtract_money(amount: int):
	#maziau 0 pinigu nebus
	if money < amount:
		money = 0
		return
	money -= amount
	money_changed.emit(money)
	
#naudoju viena karta, kai label pirma karta atsiranda
func get_money() -> int:
	return money
