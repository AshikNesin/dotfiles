# `s` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function s() {
        if [ $# -eq 0 ]; then
                subl .
        else
                subl "$@"
        fi
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
        if [ $# -eq 0 ]; then
                vim .
        else
                vim "$@"
        fi
}



# `o` with no arguments opens current directory, otherwise opens the given
# location
function o() {
        if [ $# -eq 0 ]; then
                open .
        else
                open "$@"
        fi
}

# opens the given location
function c() {
        if [ $# -eq 0 ]; then
                code .
        else
                code "$@"
        fi
}
