extends Control

@onready var player_army := %PlayerArmy as Label
@onready var enemy_army := %EnemyArmy as Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update() -> void:
#	player_army.text = Globals.player_nation
#	enemy_army.text = Globals.enemy_army[0].ownership
	pass


func _on_btn_close_pressed() -> void:
	self.visible = false
	pass # Replace with function body.
