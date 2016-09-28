var id
var name
var description
var tasks = []

const TaskClass = preload("res://data/classes/task_class.gd")
const TimeLogClass = preload("res://data/classes/timelog_class.gd")

func _init(new_name = "Unnamed Project", new_description = "", new_tasks = []):
	name = new_name
	description = new_description
	tasks = new_tasks
	#for t in new_tasks:
	#	tasks.append(TaskClass.new(t["name"], t["description"]))

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


func add_task(new_task):
	# All tasks are stored as dictionaries
	#var task_dictionary = new_task.to_dictionary()
	tasks.append(new_task.to_dictionary())


# Updates given task (NB: must have same ID as the task you are replacing)
func update_task(new_task):
	var count = 0
	for t in tasks:
		if(t["id"] == new_task.get_id()):
			tasks.remove(count)
			tasks.insert(count, new_task.to_dictionary())
			return true
		count += 1
	return false


# Deletes task matching ID
func delete_task(id):
	var count = 0
	for t in tasks:
		if(t["id"] == id):
			tasks.remove(count)
		count += 1


# Returns Task Class object matching index
# Used when you easily want to get selected task from a list
func get_task_from_index(index):
	var t = tasks[index]
	var task = TaskClass.new()
	task.from_dictionary(t)
	return task


# Returns Task Class object matching id
# Used when you easily want to get an specific task
func get_task_from_id(id):
	for t in tasks:
		if(t["id"] == id):
			var task = TaskClass.new()
			task.from_dictionary(t)
			return task


# Returns Task Class array
func get_tasks():
	var tasks_classes = []
	
	for t in tasks:
		var task = TaskClass.new()
		task.from_dictionary(t)
		tasks_classes.append(task)
	
	return tasks_classes


func to_dictionary():
	# Convert Tasks (which is in array containing Task Class)
	# to Dictionary tasks
	var tasks_array = [] # Containing Dictionary array of Tasks
	
	# Create a dictionary of project
	var project = {
		id = id,
		name = name,
		description = description,
		tasks = tasks
	}
	
	return project