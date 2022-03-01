extends Control

export var time_between_notifications := 3.0

var notification_queue := []
var timer := -1.0

func _process(delta):
	if timer == -1.0 and notification_queue.size() != 0:
		$Label.text = notification_queue[0]
		notification_queue.remove(0)
		timer = time_between_notifications
	elif timer == 0.0:
		$Label.text = ""
		timer = -1.0
	elif timer > 0:
		timer = clamp(timer - delta, 0, time_between_notifications)
