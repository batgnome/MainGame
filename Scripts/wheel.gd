extends "res://enemRune.gd"

func set_attributes():
	add_to_group("enemy")
	attributes = {
	"name": "wheel",
	"health": 2,
	"maxSize": 2,
	"defense": 3,
	"maxMove": 6,
	"attackRange": 2,
	"attackPower": 2,
	"speed": 4,
	"sprite":"res://wheel.png",
	"group":"enemy"
}

func init():
	super.init()
	
	#debugSeed()
