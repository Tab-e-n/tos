extends NoteControl

enum {MODE_ADD_NOTE, MODE_COMMANDS, MODE_JUMP}
var mode : int = MODE_COMMANDS
var command_argument : String = ""

func _ready():
	botplay = true
	
	#print(notes)

func change_timer(delta : float):
	var time_warp : float = 1
	var shift : bool = Input.is_action_pressed("shift")
	var ctrl : bool = Input.is_action_pressed("ctrl")
	if shift:
		time_warp = 4
	if Input.is_action_pressed("left") and !ctrl:
		timer -= delta * time_warp
	if Input.is_action_pressed("right") and !ctrl:
		timer += delta * time_warp
	if Input.is_action_just_pressed("skip_backward"):
		timer -= 10 * time_warp
	if Input.is_action_just_pressed("skip_foward"):
		timer += 10 * time_warp
	$timer.text = String.num(snapped(timer, 0.001))
	#print("main ", timer)

func check_and_create_notes():
	input_modeless()
	match mode:
		MODE_ADD_NOTE:
			$mode.text = "[center]ADD/REMOVE NOTE[/center]"
			input_mode_add_note()
		MODE_COMMANDS:
			$mode.text = ""
			input_mode_commands()
		MODE_JUMP:
			$mode.text = "[center]JUMP TO TIME[/center]"
			input_mode_jump()
	
	for i in notes.keys():
		var breakout : bool = false
		for j in get_children():
			if j is Note:
				if j.hit_time == i:
					breakout = true
					break
		if breakout:
			continue
		if notes[i][0] == 2:
			if timer > float(i) - 1 and timer < float(i) + notes[i][3] + 0.25:
				make_note(float(i), notes[i][0], notes[i][1], notes[i][2], notes[i][3])
		else:
			if timer > float(i) - 1 and timer < float(i) + 0.25:
				make_note(float(i), notes[i][0], notes[i][1], notes[i][2])
			#print(i)
			#notes.erase(i)

func input_mode_add_note():
	for i in inputs.size():
		if inputs[i].as_text() in note_letters and inputs[i].pressed:
			pass

func input_mode_commands():
	if Input.is_action_just_pressed("mode_add_note"):
		mode = MODE_ADD_NOTE
	if Input.is_action_just_pressed("mode_jump"):
		mode = MODE_JUMP

func input_mode_jump():
	text_edit(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."])
	$mode_extra.text = "[center]" + command_argument + "[/center]"
	if Input.is_action_just_pressed("enter"):
		if command_argument.count(".") > 1:
			$mode_extra.text = ""
			command_argument = ""
			mode = MODE_COMMANDS
		else:
			timer = float(command_argument)
			$mode_extra.text = ""
			command_argument = ""
			mode = MODE_COMMANDS

func input_modeless():
	if Input.is_action_just_pressed("esc"):
		$mode_extra.text = ""
		command_argument = ""
		mode = MODE_COMMANDS

func text_edit(text_allowed : Array):
	for i in inputs.size():
		if String.chr(inputs[i].unicode) in text_allowed and inputs[i].pressed:
			command_argument += String.chr(inputs[i].unicode)

func accuracy_text(acc_percent):
	var acc_number : float = round(acc_percent * 10000) / 100
	#$accuracy.text = String.num(acc_number)
