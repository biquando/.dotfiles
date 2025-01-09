# yazi wrapper that changes directory after exiting
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y
	if not status is-interactive
		command y $argv
		return $status
	end

	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
