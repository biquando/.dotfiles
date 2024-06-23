function download
    if not status is-interactive
        command download $argv
        return $status
    end

    if not [ (count $argv) -gt 0 ]
        echo "Usage: $0 file ..."
        return 1
    end

    for filename in $argv
        if not [ -r $filename ]
            echo "File $filename does not exist or is not readable."
            continue
        end
        if [ -d $filename ]
            echo "File $filename is a directory."
            continue
        end

        set -l filename64 (echo -n $filename | base64)
        set -l filesize (wc -c $filename | awk '{print $1}')
        printf "\033]1337;File=name=%s;size=%s:" $filename64 $filesize
        base64 <$filename
        printf '\a'
    end
end
