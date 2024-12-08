extends "res://Rune.gd"

func set_attributes():
	add_to_group("Player")
	attributes = {
	"name": "worm",
	"health": 7,
	"maxSize": 7,
	"defense": 2,
	"maxMove": 6,
	"attackRange": 1,
	"attackPower": 1,
	"speed": 3,
	"sprite":"res://worm.png",
	"group":"player"
}

func init():
	super.init()
	
	#debugSeed()
