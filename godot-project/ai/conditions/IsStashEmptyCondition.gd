extends ConditionLeaf

var stash_area:StashArea

func tick(actor, blackboard):
	if not stash_area:
		stash_area = actor.get_stash_area()
	var next_full_slot = stash_area.get_next_full_slot()
	if next_full_slot == -1:
		return SUCCESS
	return FAILURE
