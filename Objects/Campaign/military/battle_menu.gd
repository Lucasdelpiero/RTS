extends Control

@onready var playerArmy = %PlayerArmy
@onready var enemyArmy = %EnemyArmy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update():
#	playerArmy.text = Globals.playerNation
#	enemyArmy.text = Globals.enemyArmy[0].ownership
	pass


func _on_btn_close_pressed():
	self.visible = false
	pass # Replace with function body.
