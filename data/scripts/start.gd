extends Control

# Classes
const ProjectClass = preload("res://data/classes/project_class.gd")
const TaskClass = preload("res://data/classes/task_class.gd")
const DateClass = preload("res://addons/calendar_button/class/Date.gd")
const TimeLogClass = preload("res://data/classes/timelog_class.gd")
var calendar = preload("res://addons/calendar_button/class/Calendar.gd").new()
var project_manager = preload("res://data/scripts/project_manager.gd").new()

# Scenes
var tracked_item = preload("res://data/gui/scenes/tracked_item.tscn")

# --- TABS ---
# Track Time
onready var track_time_calendar_button = get_node("TabContainer/Track Time/scroll_container/vbox/hbox/calendar_button")
onready var track_time_label_selected_day = get_node("TabContainer/Track Time/scroll_container/vbox/hbox/label_selected_day")
onready var track_time_dropdown_projects = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox/vbox_left/hbox_project/dropdown_projects")
onready var track_time_dropdown_tasks = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox/vbox_right/hbox_task/dropdown_tasks")
onready var track_time_line_edit_start_time = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox/vbox_left/hbox_start_time/hbox_buttons/line_edit_start_time")
onready var track_time_line_edit_finish_time = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox/vbox_right/hbox_finish/hbox_buttons/line_edit_finish_time")
onready var track_time_line_edit_duration = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox/vbox_left/hbox_duration/hbox_buttons/line_edit_duration")
onready var track_time_button_confirm_track_time = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox_confirm/button_confirm_track_time")

onready var track_time_text_edit_notes = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/hbox 3/text_edit_notes")
onready var track_time_vbox_tracked = get_node("TabContainer/Track Time/scroll_container/vbox/vbox/vbox_tracked")


# Projects
onready var projects_line_edit_project_name = get_node("TabContainer/Projects/vbox_project_list/vbox_manage_new/hbox1/vbox_left/hbox_project/line_edit_project_name")
onready var projects_text_edit_notes = get_node("TabContainer/Projects/vbox_project_list/vbox_manage_new/hbox1/vbox_left/hbox_task/text_edit_notes")
onready var projects_item_list_projects = get_node("TabContainer/Projects/vbox_project_list/vbox_project_list/item_list_projects")
onready var projects_button_create_project = get_node("TabContainer/Projects/vbox_project_list/vbox_manage_new/hbox_confirm/button_create_project")
onready var projects_button_save_project = get_node("TabContainer/Projects/vbox_project_list/vbox_manage_new/hbox_confirm/button_save_project")
onready var projects_button_delete_project = get_node("TabContainer/Projects/vbox_project_list/vbox_manage_new/hbox_confirm/button_delete_project")

# Tasks
onready var tasks_dropdown_projects = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox1/vbox_left/hbox_project_selection/dropdown_projects")
onready var tasks_line_edit_task_name = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox1/vbox_left/hbox_task_name/line_edit_task_name")
onready var tasks_text_edit_task_notes = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox1/vbox_left/hbox_task_notes/text_edit_task_notes")
onready var tasks_item_list_tasks = get_node("TabContainer/Tasks/vbox_tasks/vbox_task_list/item_list_tasks")
onready var tasks_button_create_task = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox_confirm/button_create_task")
onready var tasks_button_save_task = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox_confirm/button_save_task")
onready var tasks_button_delete_task = get_node("TabContainer/Tasks/vbox_tasks/vbox_manage_new/hbox_confirm/button_delete_task")


# Selected Items
var selected_date = null
var selected_project = null
var selected_project_task = null


# Bool for workflow control
var edit_mode_project = false # Used to keep track of edit mode
var edit_mode_task = false


func _ready():
	# Setup connection with CalendarButton
	track_time_calendar_button.connect("date_selected", self, "update_date")
	selected_date = DateClass.new() # Get current date
	update_date(selected_date)
	
	# Setup initial selected project task
	var projects = project_manager.get_all_projects()
	if(projects.size() > 0):
		selected_project = projects[0]
		if(selected_project.get_tasks().size() > 0):
			selected_task = selected_project.get_tasks()[0]
	
	load_data()
	
	# Used for keeping track of time in real time
	set_process(true)
	
	pass


# Runs each time you select a date in the CalendarButton
func update_date(date_obj):
	selected_date = date_obj
	track_time_label_selected_day.set_text(selected_date.date("WW, MM dd YY"))
	load_timelogs()
	pass


# Loads data on start (run once)
func load_data():
	var projects = project_manager.get_all_projects()

	projects_item_list_projects.clear()
	track_time_dropdown_projects.clear()
	tasks_dropdown_projects.clear()
	
	# SETUP PROJECTS
	# Fill lists and dropdowns with project names
	for p in projects:
		projects_item_list_projects.add_item(p.get_name())
		track_time_dropdown_projects.add_item(p.get_name())
		tasks_dropdown_projects.add_item(p.get_name())
	
	# SETUP TASKS
	# Fill in tasks that belongs to the currently selected projects
	if(projects.size() > 0):
		tasks_item_list_tasks.clear()
		track_time_dropdown_tasks.clear()
		
		if(selected_project != null):
			# When you have selected a project, load tasks appropriate to that project
			for t in project_manager.get_tasks(selected_project.get_id()):
				tasks_item_list_tasks.add_item(t.get_name())
				track_time_dropdown_tasks.add_item(t.get_name())
			load_timelogs()
		#else:
		#	# If we have not manually set any project, get tasks from first project (ID 0)
		#	for t in project_manager.get_tasks(projects[0].get_id()):
		#		tasks_item_list_tasks.add_item(t.get_name())
		#		track_time_dropdown_tasks.add_item(t.get_name())
	


func load_timelogs():
	if(selected_project != null && selected_task != null && selected_date != null):
		if(is_editing_timelog):
			track_time_vbox_tracked.clear() # Clear if we have updated
			is_editing_timelog = false
		track_time_vbox_tracked.load_timelogs(selected_project, selected_task, selected_date)
	else:
		track_time_vbox_tracked.clear()


# UPDATE GUI
func update_gui():
	if(!edit_mode_project):
		projects_line_edit_project_name.set_text("")
		projects_text_edit_notes.set_text("")
		projects_button_create_project.set_text("Create")
		projects_button_save_project.set_disabled(true)
		projects_button_delete_project.set_disabled(true)
	else:
		projects_button_create_project.set_text("New")
		projects_button_save_project.set_disabled(false)
		projects_button_delete_project.set_disabled(false)
		pass

func update_gui_tasks():
	if(!edit_mode_task):
		tasks_line_edit_task_name.set_text("")
		tasks_text_edit_task_notes.set_text("")
		tasks_button_create_task.set_text("Create")
		tasks_button_save_task.set_disabled(true)
		tasks_button_delete_task.set_disabled(true)
	else:
		tasks_button_create_task.set_text("New")
		tasks_button_save_task.set_disabled(false)
		tasks_button_delete_task.set_disabled(false)
		pass

# RIGHT ARROW (NEXT DAY)
func _on_tex_btn_right_pressed():
	var day = selected_date.day()
	day += 1
	
	if(day > calendar.get_number_of_days(selected_date.month(), selected_date.year())):
		var month = selected_date.month()
		month += 1
		if(month > 12):
			month = 1
			var year = selected_date.year() + 1
			selected_date.set_year(year)
		
		selected_date.set_month(month)
		day = 1
		
	selected_date.set_day(day)
	track_time_label_selected_day.set_text(selected_date.date("WW, MM dd YY"))
	load_timelogs()

# LEFT ARROW (PREVIOUS DAY)
func _on_tex_btn_left_pressed():
	var day = selected_date.day()
	day -= 1
	
	if(day < 1):
		var month = selected_date.month()
		month -= 1
		if(month < 1):
			month = 12
			var year = selected_date.year() - 1
			selected_date.set_year(year)
		selected_date.set_month(month)
		day = calendar.get_number_of_days(selected_date.month(), selected_date.year())
		
	selected_date.set_day(day)

	track_time_label_selected_day.set_text(selected_date.date("WW, MM dd YY"))
	load_timelogs()

# Updates project
func update_project(project):
	project_manager.update_project(project)



# CREATE NEW PROJECT
func _on_button_create_project_pressed():
	# If we are in edit mode, clear everything and update buttons
	if(edit_mode_project):
		# Toggle to false so when refresh() runs, the gui updates accordingly
		edit_mode_project = false
		update_gui()
	else:
		# Error check (Cannot be empty)
		if(projects_line_edit_project_name.get_text() == ""):
			return
		
		# Create project
		var new_project = ProjectClass.new(projects_line_edit_project_name.get_text(), projects_text_edit_notes.get_text())
		
		if(project_manager.add_project(new_project)):
			projects_line_edit_project_name.set_text("")
			projects_text_edit_notes.set_text("")
			pass
		else:
			# failed to create
			pass
		
		# Add new project to existing lists (at the back in same order the projects were created)
		projects_item_list_projects.add_item(new_project.get_name())
		track_time_dropdown_projects.add_item(new_project.get_name())
		tasks_dropdown_projects.add_item(new_project.get_name())
		
		# Set project as selected_project if the total project size is 1
		if(project_manager.get_all_projects().size() == 1):
			selected_project = new_project


# SAVE UPDATED PROJECT
func _on_button_save_project_pressed():
	# Error check (Cannot be empty)
	if(projects_line_edit_project_name.get_text() == ""):
		return
	
	# Create project
	var new_project = selected_project
	new_project.set_name(projects_line_edit_project_name.get_text())
	new_project.set_description(projects_text_edit_notes.get_text())

	# Attempt to replace project
	if(project_manager.update_project(new_project)):
		edit_mode_project = false
		
 		# Project List in Projects
		projects_item_list_projects.set_item_text(index_editing, new_project.get_name())

		# Project Dropdown in "Track Time"
		var temp_selected_index = track_time_dropdown_projects.get_selected()
		track_time_dropdown_projects.set_item_text(index_editing, new_project.get_name())
		track_time_dropdown_projects.select(temp_selected_index)
		# If current selected index is equal to the one we are editing
		if(temp_selected_index == index_editing):
			track_time_dropdown_projects.set_text(new_project.get_name())
			pass
		
		# Project Dropdown in "Tasks"
		temp_selected_index = tasks_dropdown_projects.get_selected()
		tasks_dropdown_projects.set_item_text(index_editing, new_project.get_name())
		tasks_dropdown_projects.select(temp_selected_index)
		if(temp_selected_index == index_editing):
			tasks_dropdown_projects.set_text(new_project.get_name())
			pass

		update_gui()
	else:
		# failed to create project due to an error
		pass
	


# DELETE PROJECT
func _on_button_delete_project_pressed():
	if(project_manager.delete_project(selected_project.get_id())):
		edit_mode_project = false
		
		# Save currently selected projects on each dropdown
		var selected_ids = [track_time_dropdown_projects.get_selected(), tasks_dropdown_projects.get_selected()]
		
		# Clear all lists
		projects_item_list_projects.clear()
		track_time_dropdown_projects.clear()
		tasks_dropdown_projects.clear()
		
		# Get all projects
		var projects = project_manager.get_all_projects()
		
		# Fill lists
		for p in projects:
			projects_item_list_projects.add_item(p.get_name())
			track_time_dropdown_projects.add_item(p.get_name())
			tasks_dropdown_projects.add_item(p.get_name())
		
		# Make sure selected item is perserved; else go to the top (if same item is deleted)
		# Track Time Project Dropdown
		if(index_editing < selected_ids[0]):
			track_time_dropdown_projects.select(selected_ids[0]-1)
		elif(index_editing == selected_ids[0]):
			track_time_dropdown_projects.select(0)
		else:
			track_time_dropdown_projects.select(selected_ids[0])
		
		# Tasks Project Dropdown
		if(index_editing < selected_ids[1]):
			tasks_dropdown_projects.select(selected_ids[1]-1)
		elif(index_editing == selected_ids[1]):
			tasks_dropdown_projects.select(0)
			# Clear tasks since we deleted the project that was selected
			edit_mode_task = false
			reload_tasks_dropdown()
			update_gui_tasks()
		else:
			tasks_dropdown_projects.select(selected_ids[1])
		
		# Update GUI
		update_gui()
		
		# Update track time confirm button
		update_confirm_btn()


# DOUBLECLICK PROJECT IN PROJECT_LIST
var index_editing
func _on_item_list_projects_item_activated( index ):
	edit_mode_project = true
	index_editing = index
	var projects = project_manager.get_all_projects()
	selected_project = projects[index]
	
	# Update GUI with selected project (for editing)
	projects_line_edit_project_name.set_text(selected_project.get_name())
	projects_text_edit_notes.set_text(selected_project.get_description())
	
	update_gui()


# ON PROJECTS DROPDOWN_PROJECT SELECTED
func _on_dropdown_track_projects_item_selected(index):
	selected_project = project_manager.get_project_from_index(index)
	
	# Try to get task
	if(selected_project.get_tasks().size() != 0):
		selected_task = selected_project.get_tasks()[0]
	else:
		selected_task = null
	
	reload_tasks_dropdown()
	pass # replace with function body

# ON PROJECTS DROPDOWN_TASK SELECTED
func _on_dropdown_tasks_item_selected( ID ):
	selected_task = selected_project.get_tasks()[ID]
	load_timelogs()
	pass # replace with function body

# RELOAD TASKS DROPDOWN ON TRACK TIME
func reload_tasks_dropdown():
		var projects = project_manager.get_all_projects()
		
		# Store selected indexes
		var selected_index = [track_time_dropdown_projects.get_selected(), tasks_dropdown_projects.get_selected()]
		
		track_time_dropdown_tasks.clear()
		tasks_item_list_tasks.clear()
		
		if(selected_index[0] != -1):
			var tasks = projects[selected_index[0]].get_tasks()
			for t in tasks:
				track_time_dropdown_tasks.add_item(t.get_name())
		
		if(selected_index[1] != -1):
			var tasks = projects[selected_index[1]].get_tasks()
			for t in tasks:
				tasks_item_list_tasks.add_item(t.get_name())
		
		update_confirm_btn()
		load_timelogs()


func update_confirm_btn():
	# Update track time confirm button
		if(track_time_dropdown_tasks.get_selected() != -1 && track_time_line_edit_start_time.get_text() != ""):
			track_time_button_confirm_track_time.set_disabled(false)
		else:
			track_time_button_confirm_track_time.set_disabled(true)

# ------------------------------- #

# CREATE TASK
func _on_button_create_task_pressed():
	# If we are in edit mode, clear everything and update buttons
	if(edit_mode_task):
		edit_mode_task = false
		update_gui_tasks()
	else:
		# Error check (Task name or project cannot be empty)
		if(tasks_line_edit_task_name.get_text() == "" || tasks_dropdown_projects.get_text() == ""):
			return
		
		# Create task
		var new_task = TaskClass.new(tasks_line_edit_task_name.get_text(), tasks_text_edit_task_notes.get_text())
		
		# Get selected project
		var project = project_manager.get_all_projects()[tasks_dropdown_projects.get_selected()]

		# Add the new task to selected project
		if(project_manager.add_task(project.get_id(), new_task)):
			tasks_line_edit_task_name.set_text("")
			tasks_text_edit_task_notes.set_text("")
			pass
		else:
			# failed to create project due to error
			pass
		
		# Add new task to existing lists
		tasks_item_list_tasks.add_item(new_task.get_name())
		
		# If we have same project selected in Track Time, add there too
		if(track_time_dropdown_projects.get_selected() == tasks_dropdown_projects.get_selected()):
			track_time_dropdown_tasks.add_item(new_task.get_name())
			
			if(track_time_dropdown_tasks.get_item_count() == 1):
				track_time_dropdown_tasks.select(0)
				track_time_dropdown_tasks.set_text(new_task.get_name())
		
		update_confirm_btn()
	


# SAVE UPDATED TASK
func _on_button_save_task_pressed():
	if(tasks_line_edit_task_name.get_text() == "" || tasks_dropdown_projects.get_text() == ""):
		return
	
	# Create a duplicate task, overwrite name and description
	var new_task = selected_task
	new_task.set_name(tasks_line_edit_task_name.get_text())
	new_task.set_description(tasks_text_edit_task_notes.get_text())
	
	var new_project = selected_project_task
	
	if(new_project.update_task(new_task)):
		edit_mode_task = false
		
		# Update item list tasks (same page you are on right now)
		tasks_item_list_tasks.set_item_text(task_index_editing, new_task.get_name())
		
		# Update task dropdown in Projects (if current project is selected)
		if(track_time_dropdown_projects.get_selected() == tasks_dropdown_projects.get_selected()):
			if(track_time_dropdown_tasks.get_selected() == task_index_editing):
				track_time_dropdown_tasks.set_text(new_task.get_name())
			track_time_dropdown_tasks.set_item_text(task_index_editing, new_task.get_name())
		
		update_gui_tasks()
		
		project_manager.update_project(new_project)


# ON DELETE TASK
func _on_button_delete_task_pressed():
	# Create a duplicate task, overwrite name and description
	var new_project = selected_project_task
	var task_to_delete = selected_task
	
	new_project.delete_task(task_to_delete.get_id())
	
	if(project_manager.update_project(new_project)):
		edit_mode_task = false
		
		# Remove task item from Tasks
		tasks_item_list_tasks.remove_item(task_index_editing)
		
		# Update task dropdown in Projects (if same project is selected)
		if(track_time_dropdown_projects.get_selected() == tasks_dropdown_projects.get_selected()):
			
			# Store selected index
			var track_time_task_selection = track_time_dropdown_tasks.get_selected()
			
			# Remove item at same task index from Tasks that you want to delete
			track_time_dropdown_tasks.remove_item(task_index_editing)

			
			# If we deleted the same index that was selected in Track Time and Tasks, set task to 0 (as long as it is not empty
			if(track_time_task_selection == task_index_editing && track_time_dropdown_tasks.get_item_count() != 0):
				track_time_dropdown_projects.select(tasks_dropdown_projects.get_selected())
				track_time_dropdown_tasks.select(0)
				track_time_dropdown_tasks.set_text(track_time_dropdown_tasks.get_item_text(0))
			# If we have 1 item (before deleting anything from same project), clear text as there wont be any items left
			elif(track_time_dropdown_tasks.get_item_count() == 0):
				track_time_dropdown_tasks.clear()
				track_time_button_confirm_track_time.set_disabled(true)
				
		update_gui_tasks()


# ON DROPDOWN SELECTED
func _on_dropdown_projects_item_selected( ID ):
	var projects = project_manager.get_all_projects()
	selected_project_task = projects[ID]
	tasks_item_list_tasks.clear()
	
	if(selected_project_task != null):
		for t in selected_project_task.get_tasks():
			tasks_item_list_tasks.add_item(t.get_name())
	
	edit_mode_task = false
	update_gui_tasks()


var task_index_editing
var selected_task
# DOUBLECLICK TASK IN TASK_LIST
func _on_item_list_tasks_item_activated( index ):
	edit_mode_task = true
	update_gui_tasks()
	
	task_index_editing = index
	var projects = project_manager.get_all_projects()
	selected_project_task = projects[tasks_dropdown_projects.get_selected()]
	selected_task = selected_project_task.get_task_from_index(index)
	
	# Update GUI with project data
	tasks_line_edit_task_name.set_text(selected_task.get_name())
	tasks_text_edit_task_notes.set_text(selected_task.get_description())
	
	# refresh()
	pass # replace with function body


# Button NOW on start time
func _on_button_start_now_pressed():
	# Get time
	var time = OS.get_time()
	var timestamp_start = str(time["hour"]) + ":" + str(time["minute"]) + ":" + str(time["second"])
	
	# Update time
	track_time_line_edit_start_time.set_text(timestamp_start)
	
	update_time(track_time_line_edit_start_time)
	update_duration()
	update_confirm_btn()


# Button NOW on finish time
func _on_button_finish_now_pressed():
	# Get time
	var time = OS.get_time()
	var timestamp_finish = str(time["hour"]) + ":" + str(time["minute"]) + ":" + str(time["second"])
	
	# Update time
	track_time_line_edit_finish_time.set_text(timestamp_finish)
	
	update_time(track_time_line_edit_finish_time)
	update_duration()


func _on_button_start_minus_pressed():
	decrease_time(track_time_line_edit_start_time, 5)
	update_duration()
	update_confirm_btn()

func _on_button_start_plus_pressed():
	increase_time(track_time_line_edit_start_time, 5)
	update_duration()
	update_confirm_btn()

func _on_button_finish_minus_pressed():
	decrease_time(track_time_line_edit_finish_time, 5)
	update_duration()

func _on_button_finish_plus_pressed():
	increase_time(track_time_line_edit_finish_time, 5)
	update_duration()

# Validify time on Start
func _on_line_edit_start_time_focus_exit():
	update_time(track_time_line_edit_start_time)
	update_duration()
	update_confirm_btn()
	pass # replace with function body


# Validify time on Finish
func _on_line_edit_finish_time_focus_exit():
	update_time(track_time_line_edit_finish_time)
	update_duration()




var is_editing_timelog = false
var editing_timelog
func edit_timelog(timelog):
	editing_timelog = timelog
	track_time_line_edit_start_time.set_text(timelog.get_time_start())
	track_time_line_edit_finish_time.set_text(timelog.get_time_finish())
	track_time_text_edit_notes.set_text(timelog.get_notes())
	is_editing_timelog = true
	update_confirm_btn()


func delete_timelog(timelog):
	# Get INDEXES for selected project and task
	var index_of_selected_project = track_time_dropdown_projects.get_selected()
	var index_of_selected_task = track_time_dropdown_tasks.get_selected()

	# Get selected project
	var projects = project_manager.get_all_projects()
	var project = projects[index_of_selected_project]
	
	# Get selected task
	var tasks = selected_project.get_tasks()
	var task = tasks[index_of_selected_task]
	
	# Delete Timelog
	task.remove_timelog(timelog)
	project.update_task(task)
	project_manager.update_project(project)
	
	# Load timelogs
	load_timelogs()


# Create timelog and insert into task
func _on_button_confirm_track_time_pressed():
	# Make sure we have a start_time
	if(track_time_line_edit_start_time.get_text() != ""):
		# Get INDEXES for selected project and task
		var index_of_selected_project = track_time_dropdown_projects.get_selected()
		var index_of_selected_task = track_time_dropdown_tasks.get_selected()
	
		# Get selected project
		var projects = project_manager.get_all_projects()
		selected_project = projects[index_of_selected_project]
		
		# Get selected task
		var tasks = selected_project.get_tasks()
		selected_task = tasks[index_of_selected_task]
		
		# Get start time
		var time = track_time_line_edit_start_time.get_text()
		
		# Check if we have a finishing time
		if(track_time_line_edit_finish_time.get_text() != ""):
			# Create timelog
			var timelog
			
			if(is_editing_timelog):
				timelog = editing_timelog
				timelog.set_time_start(time)
			else:
				timelog = TimeLogClass.new(selected_date, time)
			
			timelog.set_notes(track_time_text_edit_notes.get_text())
			
			# Set finishing time and add to tasks's timelogs
			timelog.set_time_finish(track_time_line_edit_finish_time.get_text())
			
			if(is_editing_timelog):
				selected_task.update_timelog(timelog)
			else:
				# Save the new timelog to task
				selected_task.add_timelog(timelog)
			pass
		# Else we dont have any finishing time; and we want a live timer
		else:
			# Create timelog
			var timelog = TimeLogClass.new(selected_date, time)
			timelog.set_notes(track_time_text_edit_notes.get_text())
			
			# Save the new timelog to task and start timer on it
			selected_task.add_timelog(timelog)
			pass
		
		# Update task in project
		selected_project.update_task(selected_task)
		
		# Update project in project manager
		project_manager.update_project(selected_project)
		
		# Load timelogs
		load_timelogs()
		
		# Clear input
		track_time_line_edit_start_time.set_text("")
		track_time_text_edit_notes.set_text("")
		track_time_line_edit_finish_time.set_text("")
		track_time_line_edit_duration.set_text("00:00:00")
		
		pass # replace with function body


# Updates the duration being displayed correctly relative to match time_start/finish
func update_duration():
	var hours = 0
	var minutes = 0
	var seconds = 0
	
	# If we have a final time (start and finish)
	if(track_time_line_edit_start_time.get_text() != "" && track_time_line_edit_start_time != null && track_time_line_edit_finish_time.get_text() != "" && track_time_line_edit_finish_time != null):
		var time_start = get_total_from_text(track_time_line_edit_start_time.get_text())
		var time_finish = get_total_from_text(track_time_line_edit_finish_time.get_text())
		
		var difference = 0
		
		# Get difference
		if(time_start > time_finish):
			difference = time_start - time_finish
		else:
			difference = time_finish - time_start
		
		seconds = difference % 60
		minutes = difference / 60 % 60
		hours = difference  / 60 / 60 % 60
	
	track_time_line_edit_duration.set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))
	var duration = {}
	duration["hour"] = hours
	duration["minute"] = minutes
	duration["second"] = seconds
	return duration

func get_total_from_text(text):
	if(text != null && text != ""):
		var split = text.split(":")
		var hours = int(split[0])
		var minutes = int(split[1])
		var seconds = 0
		if(split.size() > 2):
			seconds = int(split[2])
		return (hours * 60 * 60) + (minutes * 60) + seconds
	return false


# Deformats time and creates a dictionary with hour, minute and total (calculated in minutes)
func get_dict_time_from_text(text):
	var dict = {}
	var split = text.split(":")
	var hours = int(split[0])
	var minutes = int(split[1])
	dict["hour"] = hours
	dict["minute"] = minutes
	dict["total"] = minutes + (hours * 60) # total time in minutes
	return dict


# Updates the time with correct time format regardless of user input
func update_time(node):
	var hours = 0
	var minutes = 0
	var seconds = 0
	
	var text = node.get_text()
	
	# If nothing is entered, we allow it to remain cleared
	if(text == ""):
		return
	
	var split = text.split(":")
	
	# One integer
	if(split.size() == 1):
		var number_string = split[0]
		
		# If we have 4 or greater in integer length (only save first 4)
		if(number_string.length() > 3):
			hours = int(number_string.substr(0,2))
			minutes = int(number_string.substr(2,2))
		elif(number_string.length() == 3):
			hours = int(number_string.substr(0,1))
			minutes = int(number_string.substr(1,3))
		# If we have two or less in integer length
		elif(number_string.length() > 0):
			hours = int(number_string.substr(0, number_string.length()))
	
	if(split.size() == 2 || split.size() == 3):
		var hours_string = split[0]
		var minutes_string = split[1]
		
		if(hours_string.length() > 1):
			hours = int(hours_string.substr(0,2))
		else:
			hours = int(hours_string)
		
		if(minutes_string.length() > 1):
			minutes = int(minutes_string.substr(0,2))
		else:
			minutes = int(minutes_string)
	
	if(split.size() == 3):
		var seconds_string = split[2]
		if(seconds_string.length() > 1):
			seconds = int(seconds_string.substr(0,2))
		else:
			seconds = int(seconds_string)
		
		
		pass
	if(hours < 0 || hours > 23):
		hours = 0
		
	if(minutes < 0 || minutes > 59):
		minutes = 0
	
	if(seconds < 0 || seconds > 59):
		seconds = 0
	
	node.set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))


# Used to increase time by X amounts
func increase_time(node, increase):
	var hours = 0
	var minutes = 0
	var seconds = 0
	# Makes sure time is correctly formatted
	update_time(node)
	
	var time = node.get_text()
	
	# As long as it is not empty
	if(time != ""):
		var split = time.split(":")
		hours = int(split[0])
		minutes = int(split[1])
		seconds = int(split[2])
		
		# Increase time by 5
		minutes += increase
		
		# If minutes is 60 or above; increase hour by 1 and put difference in minutes
		if(minutes > 59):
			hours += 1
			minutes -= 60
		
		# If we have incremented hours to 24, turn it to 0
		if(hours == 24):
			hours = 0
		pass
	else:
		# Starting minute value at 5 if nothing is has been set previously
		minutes = 5
	
	# Update finish time
	node.set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))



# Used to decrease time by X amounts
func decrease_time(node, decrease):
	var hours = 0
	var minutes = 0
	var seconds = 0
	# Makes sure time is correctly formatted
	update_time(node)
	var time = node.get_text()
	
	# As long as it is not empty
	if(time != ""):
		var split = time.split(":")
		hours = int(split[0])
		minutes = int(split[1])
		seconds = int(split[2])
		
		# Decrease time
		minutes -= decrease
		
		# If minutes is 60 or above; increase hour by 1 and put difference in minutes
		if(minutes < 0):
			hours -= 1
			minutes += 60
		
		# If we have decreased it to less than 0, turn it to 23
		if(hours == -1):
			hours = 23
		pass
	else:
		# No value set, decrease from 00:00, which is 23:55
		hours = 23
		minutes = 55
	
	# Update finish time
	node.set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))


