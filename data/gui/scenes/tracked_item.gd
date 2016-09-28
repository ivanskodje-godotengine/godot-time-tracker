tool
extends PanelContainer

export var is_active = false setget set_active

signal play_pressed()
signal edit_pressed()
signal delete_pressed()
signal stop_pressed()

var _project
var _task
var _timelog

func _init(project, task, timelog):
	_project = project
	_task = task
	_timelog = timelog
	
	update()
	pass

func update():
	get_node("container/column_1/task_description").set_text(str(_timelog.get_notes()))
	get_node("container/column_1/project_name_task_name").set_text(_project.get_name() + " - " + _task.get_name())
	get_node("container/column_2/time_before_after").set_text(str(_timelog.get_time_start()) + " - " + str(_timelog.get_time_finish()))


func set_active(value):
	if(get_node("normal_bg") != null && get_node("active_bg") != null):
		is_active = value
		
		if(value):
			get_node("normal_bg").hide()
			get_node("active_bg").show()
			get_node("hbox/hbox/hbox_menu_normal").hide()
			get_node("hbox/hbox/hbox_menu_active").show()
		else:
			get_node("active_bg").hide()
			get_node("normal_bg").show()
			get_node("hbox/hbox/hbox_menu_active").hide()
			get_node("hbox/hbox/hbox_menu_normal").show()

# PLAY 
# ( Creates a new timelog with same data except time_start/finish )
func _on_btn_play_pressed():
	# emit_signal("play_pressed", self)
	set_active(true)
	pass # replace with function body

# EDIT
func _on_btn_edit_pressed():
	# emit_signal("delete_pressed", self)
	pass # replace with function body

# DELETE
func _on_btn_delete_pressed():
	# emit_signal("play_pressed", self)
	pass # replace with function body

# STOP
func _on_btn_stop_pressed():
	emit_signal("stop_pressed", self)
	set_active(false)
	pass # replace with function body
