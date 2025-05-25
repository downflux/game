# gd-game project

Godot project directory.

`gd` automatically creates this project and links the appropriate DLL and
GDExtension files. This Godot project still accept GDScript files and custom
in-editor nodes, as well as nodes and behavior as defined in the Golang files.

## Sprite3D

When importing 2D graphics for `Sprite3D` billboards, make sure to

1. set `Sprite3DBase.flags.texture_filter = TEXTURE_FILTER_NEAREST`
1. set import options for the PNG file as `Import as Texture2D` and
   `Compress.Mode = Lossless`
