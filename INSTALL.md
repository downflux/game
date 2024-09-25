# Installation

**N.B.**: Ensure symlinks are checked out as symlinks and not plaintext files.

    ```sh
    git config core.symlinks true
    ```

## Windows

### Grow Graphics

See [documentation](https://learn.grow.graphics/documentation/)

1. Install `gd`
    ```sh
    go.exe install grow.graphics/gd/cmd/gd@master
    ```
1. Ensure the Godot v4.3 binary is installed as `godot-4.3.exe` in `${GOPATH}/bin`
    ```sh
    go.exe env GOPATH
    ```
1. Install `gcc` toolchain from https://winlibs.com/#download-release
1. Set Windows `${PATH}` to the appropriate `mingw64\bin` directory
