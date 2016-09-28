# Variables
var _day
var _month
var _year

# Text constants
const DAY = [
"First", "Second", "Third", "Fourth", 
"Fifth", "Sixth", "Seventh", "Eighth", 
"Ninth", "Tenth", "Eleventh", "Twelfth",
"Thirteenth", "Fourteenth", "Fifteenth", "Sixteenth",
"Seventeenth", "Eighteenth", "Nineteenth", "Twentieth",
"Twenty-first", "Twenty-second", "Twenty-third", "Twenty-fourth",
"Twenty-fifth", "Twenty-sixth", "Twenty-seventh", "Twenty-eighth",
"Twenty-ninth", "Thirtieth", "Thirty-first"
]

const WEEKDAY = [
"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
]

const MONTH = [
"January", "February", "March", "April", 
"May", "June", "July", "August", 
"September", "October", "November", "December"
]


# Date class is intended for use to store Date objects for later use
# If you want more current time and dates, use Calendar class
func _init(d = OS.get_datetime()["day"], m = OS.get_datetime()["month"], y = OS.get_datetime()["year"]):
	_day = d
	_month = m
	_year = y


# Date Formatting Options:
# --- Day ---
# dd: 1st, 2nd, 12th, 30th
# DD: First, Second, Twelveth, Thirty-first
# D: 01, 02, 12, 30
# --- Month ---
# mm: Jan, Feb, Dec
# m: 1, 2, 12
# MM: January, February, December
# M: 01, 02, 12
# --- Year ---
# yy: 01, 14, 16
# YY: 2001, 2014, 2016
# --- Weekday ---
# w: 1, 2, 5, 7
# WW: Monday, Thueday, Friday, Sunday
# W: Mon, Thu, Fri, Sun
#
# Returns a string
func date(date_format = "D-M-yy"):	
	# w: 1, 2, 5, 7
	if("w".is_subsequence_of(date_format)):
		date_format = date_format.replace("w", str(weekday()))
	
	# WW: Monday, Thueday, Friday, Sunday
	elif("WW".is_subsequence_of(date_format)):
		date_format = date_format.replace("WW", weekday(true))
	
	# W: Mon, Thu, Fri, Sun
	elif("W".is_subsequence_of(date_format)):
		date_format = date_format.replace("W", weekday(true).substr(0,3))
	
	# dd: 1st, 2nd, 12th, 30th
	if("dd".is_subsequence_of(date_format)):
		var end = "th"
		var d = day()
		if(d == 1 || d == 21 || d == 31):
			end = "st"
		elif(d == 2 || d == 22):
			end = "nd"
		elif(d == 3 || d == 23):
			end = "rd"
		date_format = date_format.replace("dd", str(day()) + end)
	
	# DD: First, Second, Twelveth, Thirty-first
	elif("DD".is_subsequence_of(date_format)):
		date_format = date_format.replace("DD", str(DAY[day()-1]))
	
	# D: 01, 02, 12, 30
	elif("D".is_subsequence_of(date_format)):
		date_format = date_format.replace("D", str(day()).pad_zeros(2))
	
	# mm: Jan, Feb, Dec
	if("mm".is_subsequence_of(date_format)):
		date_format = date_format.replace("mm", month(true).substr(0,3))
	
	# m: 1, 2, 12
	elif("m".is_subsequence_of(date_format)):
		date_format = date_format.replace("m", str(month()))
	
	# MM: January, February, December
	elif("MM".is_subsequence_of(date_format)):
		date_format = date_format.replace("MM", month(true))
	
	# M: 01, 02, 12
	elif("M".is_subsequence_of(date_format)):
		date_format = date_format.replace("M", str(month()).pad_zeros(2))
	
	# yy: 01, 14, 16
	if("yy".is_subsequence_of(date_format)):
		date_format = date_format.replace("yy", str(year()))
	
	# YY: 2001, 2014, 2016
	elif("YY".is_subsequence_of(date_format)):
		date_format = date_format.replace("YY", str(year()))
	
	return date_format

func set_date(d, m, y):
	set_day(d)
	set_month(m)
	set_year(y)


# 1: Mon
# ...
# 7: Sun
#
# Returns an integer
func day():
	return _day

func set_day(day):
	if(day > 31):
		return
	_day = day


# 1: Jan
# ...
# 12: Dec
#
# Returns an integer
func month(get_full_name = false):
	if(get_full_name):
		return MONTH[_month-1]
	return _month

func set_month(month):
	if(month > 12):
		return
	_month = month


# Year with format "1900"
# Returns an integer
func year():
	return _year

func set_year(year):
	if(year < 0):
		return
	_year = year


# Weekday
# Returns an integer
func weekday(get_full_name = false, d = day(), m = month(), y = year()):
	var t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	y -= m < 3
	var weekday = (y + y/4 - y/100 + y/400 + t[m-1] + d) % 7
	
	if(get_full_name):
		return WEEKDAY[weekday]
	
	return weekday

