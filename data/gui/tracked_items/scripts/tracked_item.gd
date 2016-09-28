tool
extends PanelContainer

export var is_active = false setget set_active
export var note = "Tracked Item Notes" setget set_notes

signal play_pressed()
signal edit_pressed()
signal delete_pressed()
signal stop_pressed()

var _project
var _task
var _timelog

# Timer Related
var ms = 0 # Total time in ms
var diff = 0
var tick = 250 # 250ms between each tick
var running_timer = false # For toggling each timer on/off
var timer = null # Timer

onready var time_label = get_node("padding/container/column_2/time_now")


func _enter_tree():
	# Only load difference if we have no finish time
	if(_timelog.get_time_finish() == null || _timelog.get_time_finish() == ""):
		# Calculate difference between now and then
		var then = get_dict_time_from_text(_timelog.get_time_start())
		var now = OS.get_time()
		now["total"] = now["second"] + (now["minute"] * 60) + (now["hour"] * 60 * 60) # Total in seconds
		
		# Difference in seconds
		var differ = get_difference(then, now)
		
		var seconds = differ % 60
		var minutes = differ / 60 % 60
		var hours = differ  / 60 / 60 % 60
		
		var ms1 = hours * 60 * 60 * 1000
		var ms2 = minutes * 60 * 1000
		var ms3 = seconds * 1000
		
		diff = ms1 + ms2 + ms3
		
		update_label()


var delay = 250 # 250ms per tick
var current_delay = 0

func _process(delta):
	if(is_active):
		current_delay += delta * 1000
		if(current_delay > delay):
			ms += delay
			current_delay = 0
			update_label()



func _ready():
	
	set_process(true)
	
	# If this does not have an end time, it means it is an ongoing project.
	if(_timelog.get_time_finish() == null || _timelog.get_time_finish() == ""):
		# Set active
		set_active(true)
	else:
		update_duration()


func get_id():
	return _timelog.get_id()


func get_difference(then, now):
	var time_start = then["total"]
	var time_finish = now["total"]
	
	var hours = 0
	var minutes = 0
	var seconds = 0
	
	var difference = 0
	
	# Get difference
	if(time_start > time_finish):
		difference = time_start - time_finish
	else:
		difference = time_finish - time_start
	
	seconds = difference % 60
	minutes = difference / 60 % 60
	hours = difference  / 60 / 60 % 60
	
	return difference


# Updates time label (only runs when item is active)
func update_label():
	var seconds = (diff + ms) / 1000 % 60
	var minutes = (diff + ms) / 1000 / 60 % 60
	var hours = (diff + ms) / 1000 / 60 / 60 % 60

	get_node("padding/container/column_2/time_now").set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))
	

func set_data(project, task, timelog):
	_project = project
	_task = task
	_timelog = timelog
	
	update()
	pass

func update():
	if(_task != null && _project != null && _timelog != null):
		get_node("padding/container/column_1/task_description").set_text(str(_timelog.get_notes()))
		get_node("padding/container/column_1/project_name_task_name").set_text(_project.get_name() + " - " + _task.get_name())
		get_node("padding/container/column_2/time_before_after").set_text(str(_timelog.get_time_start()) + " - " + str(_timelog.get_time_finish()))

func set_notes(value):
	if(get_node("padding/container/column_1/task_description") != null):
		get_node("padding/container/column_1/task_description").set_text(value)

func set_active(value):
	if(get_node("normal_bg") != null && get_node("active_bg") != null):
		is_active = value
		
		if(value):
			get_node("normal_bg").hide()
			get_node("active_bg").show()
			get_node("padding/container/column_3/hbox_menu_normal").hide()
			get_node("padding/container/column_3/hbox_menu_active").show()
		else:
			get_node("active_bg").hide()
			get_node("normal_bg").show()
			get_node("padding/container/column_3/hbox_menu_active").hide()
			get_node("padding/container/column_3/hbox_menu_normal").show()


# Updates the duration being displayed correctly relative to match time_start/finish
func update_duration():
	var hours = 0
	var minutes = 0
	var seconds = 0
	
	# If we have a final time (start and finish)
	if(_timelog.get_time_start() != "" && _timelog.get_time_start() != null && _timelog.get_time_finish() != "" && _timelog.get_time_finish() != null):
		var time_start = get_total_from_text(_timelog.get_time_start())
		var time_finish = get_total_from_text(_timelog.get_time_finish())
		
		var difference = 0
		
		# Get difference
		if(time_start > time_finish):
			difference = time_start - time_finish
		else:
			difference = time_finish - time_start
		
		seconds = difference % 60
		minutes = difference / 60 % 60
		hours = difference  / 60 / 60 % 60
	
	get_node("padding/container/column_2/time_now").set_text(str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))


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
	if(text != null && text != ""):
		var dict = {}
		var split = text.split(":")
		var hours = int(split[0])
		var minutes = int(split[1])
		var seconds = 0
		if(split.size() > 2):
			seconds = int(split[2])
		dict["hour"] = hours
		dict["minute"] = minutes
		dict["second"] = seconds
		dict["total"] = seconds + (minutes * 60) + (hours * 60 * 60) # total time in minutes
		return dict
	return {}


# PLAY 
# ( Creates a new timelog with same data except time_start/finish )
func _on_btn_play_pressed():
	# emit_signal("play_pressed", self)
	set_active(true)
	pass # replace with function body

# EDIT
func _on_btn_edit_pressed():
	get_parent().get_parent().edit_pressed(_timelog)
	pass

# DELETE
func _on_btn_delete_pressed():
	get_parent().get_parent().delete_pressed(_timelog)
	pass
	
	# emit_signal("delete_pressed", self)
	# get_parent().remove_child(self) # temporary while debuggin
	pass # replace with function body

# STOP
func _on_btn_stop_pressed():
	var time_now = OS.get_time()
	_timelog.set_time_finish(str(time_now["hour"]).pad_zeros(2) + ":" + str(time_now["minute"]).pad_zeros(2) + ":" + str(time_now["second"]).pad_zeros(2))
	
	_task.update_timelog(_timelog)
	_project.update_task(_task)
	
	get_parent().get_parent().stop_pressed(_project)
	set_active(false)
	update()
	pass # replace with function body


func get_notes():
	return _timelog.get_notes()