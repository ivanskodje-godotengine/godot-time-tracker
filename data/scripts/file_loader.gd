extends Reference

# File Paths
# const PROJECTS_FILE = "res://projects.txt"
# const TASKS_FILE = "res://tasks.txt"

# const ProjectClass = preload("res://data/classes/project_class.gd")
# const TaskClass = preload("res://data/classes/task_class.gd")

const PROJECTS_FILE = "user://projects.txt"
const TASKS_FILE = "user://tasks.txt"

const ProjectClass = preload("res://data/classes/project_class.gd")
const TaskClass = preload("res://data/classes/task_class.gd")


# project : Project
func add_project(project, overwrite = false):
	# Load projects that we want to append to
	var projects_dictionary = load_dictionary()
	
	# Create an array to store all projects
	var projects_array = []
	if(projects_dictionary.has("projects")):
		# Append loaded projects to array
		projects_array = projects_dictionary["projects"]
	
	# Check if project already exists
	for p in projects_array:
		# If we have a match
		if(p["name"] == project.get_name()):
			if(overwrite):
				# Overwrite project with new one
				p = project.get_dictionary()
			else:
				# Prevents adding duplicated or overwriting other projects
				print("ERROR: Stopping attempt to insert project with same name")
				return false

	# Append new project to array
	projects_array.append(project.to_dictionary())
	
	# Add new projects to dictionary
	projects_dictionary["projects"] = projects_array
	
	# Save projects to file
	var file = File.new()
	file.open(PROJECTS_FILE, file.WRITE)
	file.store_string(projects_dictionary.to_json())
	file.close()
	
	return true


# Returns Dictionary of projects
func load_dictionary():
	var file = File.new()
	var raw_data
	
	if(file.open(PROJECTS_FILE, file.READ) != OK):
		return {} # Returns an empty dictionary
	else:
	 	raw_data = file.get_as_text()
	
	file.close()
	
	var loaded_dictionary = {}
	loaded_dictionary.parse_json(raw_data)

	return loaded_dictionary # Returns an Project array from file


# Return: Project array
func load_projects():
	var projects_dictionary = load_dictionary()
	
	# If we got a bool false; stop and return a bool false
	if(projects_dictionary.size() == 0):
		return [] # returns an empty array

	var projects_array = []
	for p in projects_dictionary["projects"]:
		var proj = ProjectClass.new(p["name"], p["description"], p["tasks"])
		proj.set_id(p["id"])
		projects_array.append(proj)
		pass
	
	return projects_array # Returns an Project array from file

# Input: Project array
# Return: True is Success, False is Failure
func save_projects(projects_array):
	# We want an array of dictionary so we can save it
	var projects = []
	var projects_dictionary = {}
	
	for p in projects_array:
		projects.append(p.to_dictionary())
	
	# Add new projects to dictionary
	projects_dictionary["projects"] = projects
	
	# Save projects to file
	var file = File.new()
	file.open(PROJECTS_FILE, file.WRITE)
	file.store_string(projects_dictionary.to_json())
	file.close()