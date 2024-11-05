# Put system-wide fish configuration entries here
# or in .fish files in conf.d/
# Files in conf.d can be overridden by the user
# by files with the same name in $XDG_CONFIG_HOME/fish/conf.d

# This file is run by all fish instances.
# To include configuration only for login shells, use
# if status is-login
#    ...
# end
# To include configuration only for interactive shells, use
# if status is-interactive
#   ...
# end

# set a custom prompt\
# Src: https://github.com/fish-shell/fish-shell/blob/3.7.1/share/functions/fish_prompt.fish

function fish_prompt --description 'Write out the prompt' 
    set_color $fish_color_user
    echo -n (whoami)
    set_color $fish_color_normal
    echo -n '@'
    set_color $fish_color_host_remote
    echo -n (hostname | cut -d '.' -f 1)
    echo -n '.'
    echo -n (hostname | cut -d '.' -f 2)
    echo -n ' '
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color $fish_color_normal
    echo -n ' >'
    set_color $fish_color_normal
end
