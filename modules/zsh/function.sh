mkcd() {
  [ "$#" -eq 0 ] && { echo "Usage: mkcd <dir>"; return 1; }
  mkdir -p "$1" && cd "$1"
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
  local query="$@" # multiple arguments are treated as a single string even when unquoted.
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


function gitleaks_fullscan() {
    gitleaks detect \
      --source . \
      --log-opts="--all" \
      --redact \
      --report-format json \
      --report-path gitleaks-report.json
}

ai_commit() {
  emulate -L zsh
  setopt NO_GLOB

  # Stage all current changes
  git add -A

  # If no changes are staged, abort
  if git diff --cached --quiet; then
    echo "No staged changes to commit. Aborting."
    return 1
  fi

  local diff
  diff=$(git diff --cached)

  local system_msg="You are a command line expert and commit message writer. The user has staged changes described below. Generate **only** a concise one-line git commit message in imperative mood that clearly reflects what was changed. Make sure the commit message does not include double quotes"
  local user_msg="$diff"

  local payload
  payload=$(jq -n --arg sys "$system_msg" --arg usr "$user_msg" '{
    model: "llama-3.1-8b-instant",
    temperature: 0,
    max_completion_tokens: 64,
    messages: [
      { role: "system", content: $sys },
      { role: "user", content: $usr }
    ]
  }')

  local generated_msg
  generated_msg=$(curl -s "https://api.groq.com/openai/v1/chat/completions" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${GROQ_API_KEY}" \
    -d "$payload" \
    | jq -r '.choices[0].message.content' \
    | tr -d '\000-\037' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  local cmd="git commit -m \"$generated_msg\""

  # Push the generated command into your command line buffer, ready to edit or execute
  print -z -- "$cmd"
}

alias aic='ai_commit'
