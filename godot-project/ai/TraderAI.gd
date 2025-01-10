extends BeehaveRoot

@export var ship_path: NodePath
@export var stash_area_path: NodePath
@export var boat_dock_position_path: NodePath

@onready var ship = get_node(ship_path)
@onready var stash_area = get_node(stash_area_path)
@onready var boat_dock_position = get_node(boat_dock_position_path)

func _ready():
	# ensure _ready() has been finished everywhere else
	await get_tree().root.ready
