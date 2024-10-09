# Installation

1. Ensure symlinks are checked out as symlinks and not plaintext files.

    ```sh
    git config core.symlinks true
    ```

1. Also make sure to initialize submodules and configure them for SSH access to
   prevent future pain.

    ```sh
    git submodule update --init --recursive
    git submodule update --remote --recursive  # Update all submodules
    cd third_party/gd-game-assets
    git remote set-url origin git@github.com:downflux/gd-game-assets.git
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
