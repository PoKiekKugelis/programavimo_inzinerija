extends Node

#card stuff
signal card_played(card: Card)

#player stuff
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_died

#enemy stuff
signal enemy_action_completed(enemy: TestEnemy)
signal enemy_turn_ended
