extends Control

@onready var playerArmy := %PlayerArmy as Label
@onready var enemyArmy := %EnemyArmy as Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update() -> void:
#	playerArmy.text = Globals.playerNation
#	enemyArmy.text = Globals.enemyArmy[0].ownership
	pass


func _on_btn_close_pressed() -> void:
	self.visible = false
	pass # Replace with function body.
