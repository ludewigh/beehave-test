extends BeehaveRoot

@export var stash_area_path: NodePath

@onready var stash_area = get_node(stash_area_path)

func _ready():
	# ensure _ready() has been finished everywhere else
	await get_tree().root.ready
