function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

    if functions -q fish_is_root_user; and fish_is_root_user
        set -f root true
    end


    # 1. Login
    set -f color_login normal
    set -f prompt_login (prompt_login)' '

    # 2. Private mode
    set -f color_private brblack
    set -f prompt_private ''
    if set -q fish_private_mode
        set -f prompt_private '(private) '
    end

    # 3. Current working directory
    set -f color_cwd blue
    set -f prompt_cwd (prompt_pwd -D 2)

    # 4. VCS
    set -f color_vcs cyan
    set -f prompt_vcs (fish_vcs_prompt)

    # 5. Jobs
    set -f color_jobs white
    set -l njobs (jobs | wc -l | string trim)
    set -f prompt_jobs ''
    if test "$njobs" -gt 0
        set -f prompt_jobs " ($njobs)"
    end

    # 6. Status
    set -f color_status normal
    set -q fish_color_status
        or set -g fish_color_status red
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation
        or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -f prompt_status ' '(__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    # 7. Suffix
    set -f color_suffix cyan
    if test $root
        set -f prompt_suffix '#'
    else
        set -f prompt_suffix '❯'
    end

    echo -n -s \
    (set_color $color_login)   $prompt_login    \
    (set_color $color_private) $prompt_private  \
    (set_color $color_cwd)     $prompt_cwd      \
    (set_color $color_vcs)     $prompt_vcs      \
    (set_color $color_jobs)    $prompt_jobs     \
    (set_color $color_status)  $prompt_status   \
    \n                                          \
    (set_color $color_suffix)  $prompt_suffix   \
    (set_color normal) ' '
end
