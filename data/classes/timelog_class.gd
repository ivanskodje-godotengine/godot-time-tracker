# id
var id

# Date we started
var date

# Time we started on date
var time_start

# Time we finished on date
var time_finish

# Log notes
var notes


func _init(new_date = null, new_time_start = null):
	if(new_date != null && new_time_start != null):
		date = inst2dict(new_date)
		time_start = new_time_start
		pass

func set_id(xid):
	id = xid

func get_id():
	return id

func set_date(d):
	# Dictionary
	if(typeof(d) == 20):
		date = d
		pass
	else:
		print("ERROR: set_date is of type constant : " + str(typeof(d)) + ", and has not been set yet!")
		breakpoint
		date = inst2dict(d)

func get_date():
	return dict2inst(date)

func set_time_start(start):
	time_start = start

func get_time_start():
	return time_start

func get_time_start_unix():
	print("time start: " + str(time_start))
	
	var split = time_start.split(":")
	

	pass

func set_time_finish(finish):
	time_finish = finish

func get_time_finish():
	return time_finish

func set_notes(n):
	notes = n

func get_notes():
	return notes

func from_dictionary(timelog_dict):
	set_id(timelog_dict["id"])
	set_date(timelog_dict["date"])
	set_time_start(timelog_dict["time_start"])
	set_time_finish(timelog_dict["time_finish"])
	set_notes(timelog_dict["notes"])