function run-container
    if not status is-interactive
        command run-container $argv
        return $status
    end

    if not [ (count $argv) -eq 1 ]
        echo "Usage: $0 container_name"
        return 1
    end

    docker start $argv[1]
    docker attach $argv[1]
end
