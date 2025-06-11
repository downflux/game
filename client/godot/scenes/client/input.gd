class_name DFClientInput
extends Node

@onready var input_state: DFClientInputState = $InputState


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				input_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_PRIMARY_DOWN,
				)
			elif event.is_released():
				input_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_PRIMARY_UP,
				)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				input_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_SECONDARY_DOWN,
				)
			elif event.is_released():
				input_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_SECONDARY_UP,
				)
