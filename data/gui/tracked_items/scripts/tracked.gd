extends VBoxContainer

const TrackedItemScene = preload("res://data/gui/tracked_items/tracked_item.tscn")
onready var vbox_tracked_items = get_node("vbox_tracked_items")

var _project
var _task
var timelogs = []


# Keeps track of Tracked Items
# Tracked Item Manager
func _ready():
	pass


func load_timelogs(project, task, date = null):
	# clear()
	# If we want to load timelogs on a specific date
	if(date != null):
		timelogs = task.get_all_timelogs_on_date(date)
	# Load all timelogs belonging to task regardless of date
	else:
		timelogs = task.get_all_timelogs()
	
	if(timelogs.size() == 0 || task != _task):
		clear()
	else:
		_project = project
		_task = task
	
	for t in timelogs:
		var is_bad = false
		# Iterate through children. If any of the children have the same ID, break
		for c in get_node("vbox_tracked_items").get_children():
			if(c.get_id() == t.get_id()):
				is_bad = true # We have a duplicate; dont add
				break 
		
		if(!is_bad):
			# Add to list, as it has not previously been added
			var tracked_item = TrackedItemScene.instance()
			tracked_item.set_data(project, task, t)
			vbox_tracked_items.add_child(tracked_item)
	pass

func stop_pressed(project):
	# Store changed data
	get_tree().get_root().get_node("main").update_project(project)
	pass

func edit_pressed(timelog):
	get_tree().get_root().get_node("main").edit_timelog(timelog)
	pass

func delete_pressed(timelog):
	get_tree().get_root().get_node("main").delete_timelog(timelog)


func clear():
	for c in vbox_tracked_items.get_children():
		vbox_tracked_items.remove_child(c)
	