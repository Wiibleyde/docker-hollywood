# hollywood

Dockerized [hollywood], based on Ubuntu 24.04 LTS.

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

Press `Ctrl-C` a few times, then `exit`, to quit.

## License

MIT

[hollywood]: https://github.com/dustinkirkland/hollywood
[screenshot]: screenshot.png
