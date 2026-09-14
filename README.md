# hollywood

Dockerized [hollywood], based on Debian 13 (trixie).

A tiny tool which turns your terminal into a Hollywood style real time hacking scene.

It works well on Windows, Linux and macOS if you have Docker installed.

![screenshot]

## Usage

Build the image:

```sh
docker build -t docker-hollywood .
```

Then run it:

```sh
docker run --rm -it docker-hollywood
```

**Press `q` to quit.** (`Q` and `Ctrl-C` work too.) The status bar shows the
hint in the bottom-left corner.

With Docker Compose:

```sh
docker compose run --rm --build hollywood
```

### Options

With no arguments, the number of panes is picked from the size of your
terminal, so the widgets stay readable instead of all complaining that the
terminal is too small. Everything `hollywood` accepts is forwarded and
overrides that:

```sh
docker run --rm -it docker-hollywood -s 18     # one pane per widget, whatever the size
docker run --rm -it docker-hollywood -s 6      # exactly 6 panes
docker run --rm -it docker-hollywood -d 30     # reshuffle the panes every 30 seconds
docker run --rm -it docker-hollywood --help    # the manpage
```

### Timezone

The clock in the status bar is UTC by default. Build with another one:

```sh
docker build --build-arg TZ=Europe/Paris -t docker-hollywood .
```

## License

MIT

[hollywood]: https://github.com/dustinkirkland/hollywood
[screenshot]: screenshot.png
