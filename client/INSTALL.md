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
    cd third_party/downflux/game-assets
    git remote set-url origin git@github.com:downflux/game-assets.git
    git checkout main
    ```

    Also see https://stackoverflow.com/questions/18770545/.

## Windows

### Symlinks

Recreate symlinks manually. See https://stackoverflow.com/a/59761201 -- it seems
like Windows symlink on checkout may still be corrupted.

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

1. Re-compile extensions
    ```sh
    gd.exe
    ```

1. Install `gcc` toolchain from https://winlibs.com/#download-release
1. Set Windows `${PATH}` to the appropriate `mingw64\bin` directory

## Linux

### Grow Graphics

See [documentation](https://learn.grow.graphics/documentation/)

1. Install `gd`

    ```sh
    go install grow.graphics/gd/cmd/gd@master
    ```

1. Ensure the Godot v4.3 binary is installed as `godot-4.3.exe` in `${GOPATH}/bin`

    ```sh
    go env GOPATH
    ```

1. Re-compile extensions
    ```sh
    gd
    ```
