function mullvad
    if not status is-interactive
        command mullvad $argv
        return $status
    end

    if test "$argv" = 'disconnect'; and set -q SSH_TTY
        if test (mullvad status) = 'Disconnected'
            command mullvad $argv
            return $status
        end

        function __mullvad_confirm
            while true
                read -l -P \
'You are currently connected via ssh.
Are you sure you want to disconnect from mullvad? (y/N) ' confirm
                switch $confirm
                    case Y y
                        return 0
                    case '' N n
                        return 1
                end
            end
        end
        if __mullvad_confirm
            command mullvad $argv
        end
    else
        command mullvad $argv
    end
end
