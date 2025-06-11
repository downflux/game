class_name DFClientInput
extends Node

@onready var mouse_state: DFClientInputState = $MouseState


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_PRIMARY_DOWN,
				)
			elif event.is_released():
				mouse_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_PRIMARY_UP,
				)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				mouse_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_SECONDARY_DOWN,
				)
			elif event.is_released():
				mouse_state.handle_mouse_input(
					DFClientInputState.MouseInput.MOUSE_INPUT_SECONDARY_UP,
				)
