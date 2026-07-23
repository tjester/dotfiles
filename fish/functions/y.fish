# Wraps yazi so quitting it cd's the shell to whatever directory you were
# last in. yazi can't do this itself (a subprocess can't change its parent
# shell's cwd) — it writes its last dir to --cwd-file instead, which this
# reads back and cd's to. Use `y` instead of `yazi` to get this behavior.
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
