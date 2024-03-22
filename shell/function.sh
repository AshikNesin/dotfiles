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

# https://www.emgoto.com/md-to-mdx-rename/

function migrateMDtoMDX() {
  for file in "$1"/*; do
    if [ -d "$file" ]; then
      migrateMDtoMDX "$file"
    else
      if [[ $file == *.md ]]; then
        mv "$file" "${file%.*}.mdx"
      fi
    fi
  done
}

function cleanup() {
if docker info >/dev/null 2>&1; then
    # without any confirmation    
    docker system prune -f
else
    echo "Docker is not running."
fi

brew cleanup

}