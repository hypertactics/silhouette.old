#!/bin/sh

# functions for silhouette bash wrapper

# initialize_ansi originally sourced from 
# https://intuitive.com/wicked/scripts/011-colors.txt
# notes for usage: echo -e or printf %b
initialize_ansi() {
  esc="\033"

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}

warning() {
  local msg="${1}"  
  printf "\n%b\n" "${yellowf}${boldon}${msg}${reset}"
}

notice() {
  local msg="${1}"  
  printf "\n%b\n" "${cyanf}${boldon}${msg}${reset}"
}

critical() {
  local msg="${1}"  
  printf "\n%b\n" "${redf}${boldon}${msg}${reset}"
}

ok() {
  local msg="${1}"  
  printf "\n%b\n" "${greenf}${boldon}${msg}${reset}"
}

extended_help_msg() {
  local msg="${1}"  
  printf "  %b\n" "${yellowf}${msg}${reset}"
}

help_msg() {
  local arg="${1}"  
  local msg="${2}"  
  local extended_msg="${3}"
  printf "  %b\n" "${whitef}${boldon}(${arg})${reset} ${msg}"
  if [ -n "${EXTENDED_HELP}" ]; then
    extended_help_msg "${extended_msg}"
  fi
}

build_cmd() {
  local cmd="ansible-playbook ${INTERACTIVE} ${ANSIBLE_VERBOSE} ${ANSIBLE_SYNTAX_CHECK} -i hosts site.yml"
  if [ -n "${TAGS}" ]; then
    cmd="${cmd} --tags ${TAGS}"
  fi
  echo $cmd
}

syntax_check() {
  local ansible_cmd="${1}"
  $ansible_cmd
  if [ $? -eq 0 ]; then
    ok "Syntax is okay"  
    exit 0
  fi
}

run() {
  cd $HOME/.silhouette/lib
  local ansible_cmd=$(build_cmd)
  if [ -n ${INTERACTIVE} ]; then
    syntax_check "${ansible_cmd}"
  else
    $ansible_cmd
  fi
}

list_tags() {
  cd $HOME/.silhouette/lib
  printf "%s\n" "Availble Tags"
  local ansible_cmd=$(build_cmd)
  ansible_cmd="${ansible_cmd} --list-tasks"
  $ansible_cmd
}

backup() {
  if which rsync; then
    find $HOME -maxdepth 1 -type f -iname ".*" -print0 | xargs -0 -I XX echo XX >> $HOME/.silhouette/.backups/init
    rsync -avzn --files-from $SILHOUETTE_ROOT/.backups/list
    exit 0
  else
    echo "not performing backup - TODO: add a copy command here"
    exit 2
  fi
}

tag() {
  TAGS="${TAGS} ${1}"
}

show_help() {
  EXTENDED_HELP="${1}"

  notice "Options"

  help_msg "-c" "check configuration for errors" \
    "runs ansible-playbook --syntax to check for errors in your YAML files"

  help_msg "-d" "regenerate dotifles (create the actual dotfiles)" \
    "ansible will run through the symlinking of your dotfiles to your home directory (can be mixed with other flags)"

  help_msg "-h" "this message" \
    "what else is there to say?"

  help_msg "-H" "this message: with more detailed explanations" \
    "shows help with these longer explanations"

  help_msg "-l" "regenerate links (regernate dotfile symlinks)" \
    "ansible will run generate your dotfiles to your home directory (can be mixed with other flags)"

  help_msg "-i" "interactive mode (ansible playbook interactive)" \
    "ansible-playbook will run in interactive mode prompting you to run steps (y=yes|n=no|c=continue without interaction)"

eh_p=$(cat <<EOH
this will performa a one time backup of your dotfiles and any directories that silhouette will take over management for.
  the files will be backed up to ${SILHOUETTE_ROOT}/.backups.  a file list will also be located here
EOH
)

  help_msg "-p" "initialize profle (bring your profile under silhouette control)" "${eh_p}"

  help_msg "-u" "uninstall silhouette (restores original dotfiles)" \
    "you hate this tool and you want to get rid of it, silhouette will restore your old directories/files/dotfiles from initialzation time"
}

unknown_argument() {
  local arg="${1}"
  critical "${arg} is an unknown argument. exiting!"
}

intialize_profile() {
  echo "initialize profile"  
}

init_functions() {
  initialize_ansi

  local script_directory="${1}"
  local script="${2}"

  # set some global variables for the functions above
  SILHOUETTE_ROOT="${HOME}/.${script}"
  TAGS=''
  EXTENDED_HELP=''
  INTERACTIVE=''
  ANSIBLE_VERBOSE=''
  ANSIBLE_SYNTAX_CHECK=''
  VERBOSE=false
}
