extends Node

var mouse_in_province = 1
var camera_angle := 0.0
var playerNation = "ROME"
var playerArmy = [] # Array of armies of the player
var playerArmyData : Array[ArmyData] = [] # Array of armies data each containing units
var enemyArmy = []
var enemyArmyData : Array[ArmyData] = []
var debug : Debug = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reset_armies():
	playerArmy = []
	playerArmyData = []
	enemyArmy = []
	enemyArmyData = []
