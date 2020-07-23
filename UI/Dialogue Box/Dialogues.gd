extends RichTextLabel

var delta_time = 0
export var speed = 0.1

export var confirm_action = "ui_accept"
var current_page = 0
var pages = []

var sequence1 = false

func _ready():
	pass

func _input(event):
	if(event.is_action_released(confirm_action)):
		if(visible_characters == text.length()):
			text_advance()
			if sequence1:
				char_sequence1()
				
		else:
			visible_characters = text.length()

func dialogue1():
	visible_characters = 0
	pages = dialogue_text1.split(";")
	for i in range(pages.size()):
		pages[i] = pages[i].replace("","")
	text = pages[current_page]
	set_process_input(true)
	set_process(true)
	sequence1 = true
	char_sequence1()

export(String, MULTILINE) var dialogue_text1 = "Начало теста;Этак история о тебе;\"Конец теста\";Wow."
func char_sequence1():
	if current_page == 0:
		someone()
	if current_page == 1:
		plate()
	if current_page == 2:
		someone()
	pass

func plate():
	get_parent().get_node("AnimationPlayer").play("Plate1")
	get_parent().get_node("Names").clear()
func someone():
	get_parent().get_node("Names").set_text("Рассказчик")
	get_parent().get_node("AnimationPlayer").play("Someone")


func text_advance():
	if(text.length() == visible_characters):
		current_page = current_page + 1
		visible_characters = 0
		delta_time = 0
		if(pages.size() - 1 >= current_page):
			text = pages[current_page]
		else:
			get_parent().get_parent().queue_free()

func _process(delta):
	if(delta_time > speed):
		delta_time = 0
		text_update()
	delta_time = delta_time + delta

func text_update():
	if(text.length() > visible_characters):
		visible_characters = visible_characters + 1
