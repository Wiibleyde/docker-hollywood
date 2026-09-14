FROM debian:trixie-slim

ARG TZ=UTC

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ} \
    TERM=xterm-256color \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    HOME=/home/hollywood \
    BYOBU_CONFIG_DIR=/home/hollywood/.byobu

# hollywood 1.21 ships in Debian main, so no extra apt component is needed.
# Its widgets come in through Recommends; install them explicitly together with
# --no-install-recommends so the *transitive* recommends stay out of the image.
# moreutils is deliberately absent: the "errno" widget only calls
# `errno --list`, and moreutils drags all of perl in for it -- files/errno
# replaces it with a few lines of the python3 that speedometer already needs.
# man-db/manpages are not recommended by hollywood but the "man" widget needs
# real pages to page through, and the slim base drops every man page through a
# dpkg path-exclude -- so lift that one rule (only) before installing anything.
RUN sed -i '\%^path-exclude /usr/share/man%d' /etc/dpkg/dpkg.cfg.d/* && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        hollywood \
        apg atop bmon bsdextrautils ccze cmatrix htop jp2a \
        openssh-client plocate speedometer tree \
        man-db manpages manpages-dev tini tzdata && \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mandb -q && \
    updatedb

# Upstream forwards only "$1" to the inner (in-tmux) invocation, and by then the
# option loop has already shifted it away -- so `-s`/`-d` are silently dropped.
# Forward the full argument list instead.
RUN sed -i \
        -e 's|^DELAY=10$|DELAY=10\nHOLLYWOOD_ARGS="$*"|' \
        -e 's|send-keys -t \$PKG "\$0 \$1"|send-keys -t $PKG "$0 $HOLLYWOOD_ARGS"|' \
        /usr/bin/hollywood && \
    grep -q 'HOLLYWOOD_ARGS' /usr/bin/hollywood

# speedometer builds an urwid MainLoop, and urwid grabs the mouse by default.
# Same problem as htop: the pane is killed with -9, so the terminal is left in
# mouse-reporting mode. Nothing here reacts to clicks, so turn it off.
RUN sed -i 's|urwid.MainLoop(self.top, palette=self.palette, unhandled_input=self.unhandled_input)|urwid.MainLoop(self.top, palette=self.palette, unhandled_input=self.unhandled_input, handle_mouse=False)|' \
        /usr/bin/speedometer && \
    grep -q 'handle_mouse=False' /usr/bin/speedometer

COPY files/errno /usr/local/bin/errno
COPY files/entrypoint.sh /usr/local/bin/hollywood-entrypoint
COPY files/quit.tmux.conf /etc/hollywood/quit.tmux.conf
COPY files/htoprc /etc/hollywood/htoprc

RUN useradd --create-home --home-dir "${HOME}" --shell /bin/bash hollywood && \
    mkdir -p "${BYOBU_CONFIG_DIR}" && \
    cp /etc/hollywood/quit.tmux.conf "${BYOBU_CONFIG_DIR}/.tmux.conf" && \
    mkdir -p "${HOME}/.config/htop" && \
    cp /etc/hollywood/htoprc "${HOME}/.config/htop/htoprc" && \
    chown -R hollywood:hollywood "${HOME}" && \
    chmod +x /usr/local/bin/errno /usr/local/bin/hollywood-entrypoint && \
    errno --list | grep -q '^EPERM 1 '

LABEL org.opencontainers.image.title="docker-hollywood" \
      org.opencontainers.image.description="Hollywood-style hacking scene in a container" \
      org.opencontainers.image.source="https://github.com/Wiibleyde/docker-hollywood" \
      org.opencontainers.image.licenses="MIT"

USER hollywood
WORKDIR /home/hollywood

# tini reaps the widget processes and forwards SIGTERM to the whole group, so
# `docker stop` is instant instead of waiting out the kill timeout.
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "hollywood-entrypoint"]
