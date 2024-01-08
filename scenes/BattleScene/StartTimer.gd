extends Timer

var finished = false

var seconds_left := 3

func _ready():
	$StartTimerLabel.text = "3"
	($CountdownSoundPlayer as AudioStreamPlayer2D).play()

func _process(_delta):
	if not finished:
		$StartTimerLabel.text = str(seconds_left)
	

func _on_timeout():
	if finished:
		return
	
	seconds_left -= 1
	if seconds_left > 0:
		($CountdownSoundPlayer as AudioStreamPlayer2D).play()
	
	if seconds_left <= 0:
		get_tree().paused = false
		$StartTimerLabel.queue_free()
		finished = true
