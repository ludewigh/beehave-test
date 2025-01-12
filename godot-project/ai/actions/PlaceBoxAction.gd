extends ActionLeaf

var stash_area:StashArea

func tick(actor, blackboard):
	if not stash_area and actor.get_ship():
		stash_area = actor.get_ship().get_stash_area()
	if not stash_area:
		stash_area = actor.get_stash_area()
	
	var next_available_slot = stash_area.get_next_available_slot()
	if next_available_slot != -1 and actor.is_carrying():
		stash_area.place(next_available_slot)
		actor.reset()
		return SUCCESS
	else:
		return FAILURE
