extends Node

#global variables
var in_combat = false

#card stuff
signal card_played(card: Card)

#player stuff
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_died_in_combat
signal player_died

#enemy stuff
signal enemy_action_completed(enemy: TestEnemy)
signal enemy_turn_ended
signal in_combat_status_changed
signal enter_combat(enemy: CharacterBody2D) 

#GameManager stuff
signal start_run
signal restart_at_hub
signal run_won
signal run_ended
signal run_continues
signal changing_level
