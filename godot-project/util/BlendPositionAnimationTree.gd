class_name BlendPositionAnimationTree
extends AnimationTree


@export var position: Vector2 = Vector2.ZERO: set = _set_position
@export var transition: String: set = _set_transition

var position_properties = []
var transition_property

func _ready():
	for property in get_property_list():
		if "blend_position" in property.name:
			position_properties.append(property.name)
		if "Transition/current" in property.name:
			transition_property = property.name
	
func _set_position(vec2) -> void:
	for property in position_properties:
		set(property, vec2)

func _set_transition(tran) -> void:
	transition = tran
	if transition_property != null and transition != null:
		set(transition_property, transition)
