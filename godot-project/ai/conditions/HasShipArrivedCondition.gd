extends ConditionLeaf

var ship:Ship

var arrived = false

func tick(actor, blackboard):
	if not ship:
		ship = actor.get_ship()
	if arrived or not ship.departed:
		return SUCCESS
	return FAILURE

func _set_ship(s):
	ship = s
	if not ship.is_connected("arrive", Callable(self, "_on_arrive")):
		ship.connect("arrive", Callable(self, "_on_arrive"))
	if not ship.is_connected("depart", Callable(self, "_on_depart")):
		ship.connect("depart", Callable(self, "_on_depart"))
		
func _on_arrive():
	self.arrived = true
	
func _on_depart():
	self.arrived = false
