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


unalias ai 2>/dev/null

# ai: Generate exact shell command from natural language using Groq API; reasoning off; no execution; globbing disabled
ai() {
  emulate -L zsh
  setopt NO_GLOB
  local query="$*"
  local system_msg="You are a command line expert. The user wants to run a command but they don't know how. Return ONLY the exact shell command needed. Do not prepend with an explanation, no markdown, no code blocks - just return the raw command you think will solve their query."

  local payload
  payload=$(jq -n --arg sys "$system_msg" --arg usr "$query" '{
    model: "llama-3.1-8b-instant",
    temperature: 0,
    max_completion_tokens: 256,
    messages: [
      { role: "system", content: $sys },
      { role: "user", content: $usr }
    ]
  }')

  local cmd
  cmd=$(curl -s "https://api.groq.com/openai/v1/chat/completions" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${GROQ_API_KEY}" \
    -d "$payload" \
    | jq -r '.choices[0].message.content' \
    | tr -d '\000-\037' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  print -z -- "$cmd"
}

# Ensure globbing is disabled when invoking `ai`
alias ai='noglob ai'
