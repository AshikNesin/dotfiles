## Download mp3 audio from Youbtube (need youtube-dl first)
function get-audio() {
  if [ $# -eq 0 ]; then
      print "Oops. Please enter a url: get-audio <youtube-link>"
  else
    youtube-dl --extract-audio --audio-format mp3 $1
  fi
}

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd $_
}


# Copy w/ progress
cp_p () {
  rsync -WavP --human-readable --progress $1 $2
}



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

# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
    if [ -f "$1" ] ; then
        local filename=$(basename "$1")
        local foldername="${filename%%.*}"
        local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
        local didfolderexist=false
        if [ -d "$foldername" ]; then
            didfolderexist=true
            read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                return
            fi
        fi
        mkdir -p "$foldername" && cd "$foldername"
        case $1 in
            *.tar.bz2) tar xjf "$fullpath" ;;
            *.tar.gz) tar xzf "$fullpath" ;;
            *.tar.xz) tar Jxvf "$fullpath" ;;
            *.tar.Z) tar xzf "$fullpath" ;;
            *.tar) tar xf "$fullpath" ;;
            *.taz) tar xzf "$fullpath" ;;
            *.tb2) tar xjf "$fullpath" ;;
            *.tbz) tar xjf "$fullpath" ;;
            *.tbz2) tar xjf "$fullpath" ;;
            *.tgz) tar xzf "$fullpath" ;;
            *.txz) tar Jxvf "$fullpath" ;;
            *.zip) unzip "$fullpath" ;;
            *) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
        esac
    else
        echo "'$1' is not a valid file"
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
    # transfer.sh
    transfer() {
    # write to output to tmpfile because of progress bar
    tmpfile=$( mktemp -t transferXXX )
    curl --progress-bar --upload-file $1 https://transfer.sh/$(basename $1) >> $tmpfile;
    cat $tmpfile;
    rm -f $tmpfile;
}

# opens the given location
function c() {
        if [ $# -eq 0 ]; then
                code .
        else
                code "$@"
        fi
}

## Kill a port
killport() { lsof -i tcp:"$*" | awk 'NR!=1 {print $2}' | xargs kill -9 ;}


pdf-unencrypt () {
    : "Usage: <file> <password> Uses qpdf to rewrite the file without encryption."
    local file="$1"
    local password="$2"
    qpdf --decrypt   --replace-input "$file" --password="$password" 
}