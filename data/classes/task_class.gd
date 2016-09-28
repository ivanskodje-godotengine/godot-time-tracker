const TimeLogClass = preload("res://data/classes/timelog_class.gd")

var id
var name
var description
var timelogs = []

func _init(new_name = "Unnamed Task", new_description = ""):
	name = new_name
	description = new_description

func set_id(new_id):
	id = new_id

func get_id():
	return id

func set_name(new_name):
	name = new_name

func get_name():
	return name

func set_description(new_description):
	description = new_description

func get_description():
	return description

func set_timelogs(new_timelogs):
	timelogs = new_timelogs

# Takes an Timelog class and saves it in an array as a dictionary
func add_timelog(new_timelog):
	
	# GENERATE UNIQUE ID
	var id = 0
	var has_unique_id = false
	
	while(!has_unique_id):
		var count = 0
		# Check each project
		for tl in timelogs:
			# Check if any ID matches
			if(tl["id"] != id):
				# We dont have a match, increment count as usual
				count += 1
		
		if(count == timelogs.size()):
			has_unique_id = true
			new_timelog.set_id(id) # Add unique id to project
		else:
			id += 1 # increment id for next check
	
	# Store TimeLog class as dictionary
	timelogs.append(inst2dict(new_timelog))

# Remove timelog
func remove_timelog(new_timelog):
	var count = 0
	for t in timelogs:
		if(t["id"] == new_timelog.get_id()):
			timelogs.remove(count)
			return true
		count += 1
	return false

# Updates given task (NB: must have same ID as the task you are replacing)
func update_timelog(new_timelog):
	var count = 0
	for t in timelogs:
		if(t["id"] == new_timelog.get_id()):
			timelogs.remove(count)
			timelogs.insert(count, inst2dict(new_timelog))
			return true
		count += 1
	return false


# Returns timelog class item with matching id
func get_timelog(id):
	for tl in timelogs:
		if(tl["id"] == id):
			return tl


# Returns all timelog items for this task
func get_all_timelogs():
	var timelog_items = []
	
	for tl in timelogs:
		var timelog = TimeLogClass.new()
		timelog.from_dictionary(tl)
		timelog_items.append(timelog)
	return timelog_items

func get_all_timelogs_on_date(date):
	# Get all timelog classes and add to array
	var timelog_items = []
	for t in timelogs:
		var new_timelog = TimeLogClass.new()
		new_timelog.from_dictionary(t)
		if(new_timelog.get_date().day() == date.day() && new_timelog.get_date().month() == date.month() && new_timelog.get_date().year() == date.year()):
			timelog_items.append(new_timelog)
	return timelog_items

# Sets data from dictionary
func from_dictionary(task_dict):
	set_id(task_dict["id"])
	set_name(task_dict["name"])
	set_description(task_dict["description"])
	set_timelogs(task_dict["timelogs"])

# Returns dictionary from self
func to_dictionary():
	var task = {
		id = id,
		name = name,
		description = description,
		timelogs = timelogs
	}
	return task