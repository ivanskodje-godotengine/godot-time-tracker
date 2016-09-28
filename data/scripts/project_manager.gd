
extends Node

const FileLoader = preload("res://data/scripts/file_loader.gd")
const ProjectClass = preload("res://data/classes/project_class.gd")
const TaskClass = preload("res://data/classes/task_class.gd")

# Stored projects
var projects = []

func _init():
	# Load projects when started
	projects = FileLoader.new().load_projects()

# Saves projects
func save():
	FileLoader.new().save_projects(projects)

# Adds a new project
# Returns bool to inform about success or failure
func add_project(project, overwrite = false):

	# GENERATE UNIQUE ID
	var id = 0
	var has_unique_id = false
	
	while(!has_unique_id):
		var count = 0
		# Check each project
		for p in projects:
			# Check if any ID matches
			if(p.get_id() != id):
				# We dont have a match, increment count as usual
				count += 1
		
		if(count == projects.size()):
			has_unique_id = true
			project.set_id(id) # Add unique id to project
		else:
			id += 1 # increment id for next check
	
	
	# In order to overwrite (or to avoid it) 
	# we check all projects for a match
	var count = 0
	for p in projects:
		if(p.get_id() == project.get_id()):
			if(overwrite):
				# Overwrite project
				# projects.append(p)
				projects.remove(count)
				projects.insert(count, project)
				save()
				return true
			else:
				# We found a match and dont overwrite; return false
				return false
		count += 1
	
	# No previous match; add new project to projects
	projects.append(project)
	save()
	return true


# Returns project with matching name, 
# else it will return a false bool
func get_project(id):
	# Go through each project
	for p in projects:
		if(p.get_id() == id):
			# Return matching project
			return p
	return false

func get_project_from_index(index):
	if(projects.size() != 0):
		return projects[index]
	return false

# Returns the array containing all projects (Project class)
func get_all_projects():
	return projects


# Used to update projects
# Takes in name : string, new_project: Project
# Returns a bool for error handling
func update_project(new_project):
	# Make sure both projects are valid 
	# (will be false if there is something wrong)
	var count = 0
	# Find the old project
	for p in projects:
		if(p.get_id() == new_project.get_id()):			
			# Remove old project
			projects.remove(count)
			
			# Insert your project in the same position
			projects.insert(count, new_project)
			
			# Save changes
			save()
			return true
		count += 1
	
	return false # No project to replace


# Delete project
func delete_project(id):
	var count = 0
	for p in projects:
		if(p.get_id() == id):
			projects.remove(count)
			save()
			return true
		count += 1
	return false


func add_task(project_id, task):

	for p in projects:
		if(p.get_id() == project_id):

			# GENERATE UNIQUE ID
			var id = 0
			var has_unique_id = false
			
			while(!has_unique_id):
				var count = 0
				# Check each project
				for t in p.get_tasks():
					# Check if any ID matches
					if(t.get_id() != id):
						# We dont have a match, increment count as usual
						count += 1
				
				if(count == p.get_tasks().size()):
					has_unique_id = true
					task.set_id(id) # Add unique id to project
				else:
					id += 1 # increment id for next check
			
			# No previous match; add new project to projects
			p.add_task(task)
			save()
			return true
	return false


# Returns an array of Task Class beloning to name Project
# Returns false if no task was found
func get_task(project_id, task_id):
	for p in projects:
		if(p.get_id() == project_id):
			for t in p.get_tasks():
				if(t.get_id() == task_id):
					return t
	return false

# Returns an array of Task Class beloning to name Project
func get_tasks(id):
	for p in projects:
		if(p.get_id() == id):
			return p.get_tasks()
	return []

func replace_task(project_name, task_name, new_task):
	var count = 0
	for p in projects:
		if(p.get_name() == project_name):
			# Found project p
			p.replace_task(task_name, new_task)
			save()
			return true
		count += 1
	return false

func delete_task(project_name, task_name):
	var count = 0
	for p in projects:
		if(p.get_name() == project_name):
			# Found project p
			p.delete_task(task_name)
			save()
			return true
		count += 1
	return false
	