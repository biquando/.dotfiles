function runc
    if not status is-interactive
        command runc $argv
        return $status
    end

    set -l int_file (mktemp)

    # Compile & Run
    cc $argv -o $int_file
    $int_file
    set -l exec_status $status

    rm -f $int_file
    return $exec_status
end
