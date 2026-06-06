extends Resource
class_name CharacterResource

enum State { 
	IDLE,
	PATROLLING,
	SEARCHING, 
	ENGAGING, 
	STUNNED, 
	FLEEING
	}

@export var name: String
@export var state: State = State.IDLE

# resource bars
@export_range(0, 100) var condition: int = 100
@export_range(0, 100) var energy: int = 100
@export_range(0, 100) var nerve: int = 100

# stats
@export_range(0, 100) var alert: int = 75
