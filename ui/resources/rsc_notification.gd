extends Label
class_name RscNotification

enum RSC_TYPE {
	METAL,
	FOOD,
	WATER
}

var timer := 1.5
var rsc_type: int
var amt: int


func _ready():
	if amt >= 0:
		self.text = "+"
	else:
		self.text = "-"
	self.text += str(amt) + " "
	
	match rsc_type:
		RSC_TYPE.METAL:
			self.text += "metal"
		RSC_TYPE.FOOD:
			self.text += "food"
		RSC_TYPE.WATER:
			self.text += "water"
	
	randomize()
	
	self.rect_position.x += rand_range(-50, 50)
	self.rect_position.y += rand_range(-30, 30)

func _process(delta):
	timer -= delta
	
	if timer <= 0.0:
		queue_free()
