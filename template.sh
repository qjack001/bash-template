#!/bin/bash
####  Description goes here.
#### 
####  Copyright (c) 2021 by <your name here>
####  This code is licensed under the MIT license


program="<PROGRAM_NAME>"
version="<VERSION_NUMBER>"
source_url="https://raw.githubusercontent.com/<PATH_TO_SOURCE>"


####  Mission control for handling input & deciding which function to run.
function handle_input
{
	if [ "$#" -lt "1" ];                   then no_args
	elif input "$1" "help" "h";            then show_help
	elif input "$1" "shortform" "short";   then show_short
	elif input "$1" "version" "v";         then print_version
	elif input "$1" "update" "upgrade";    then update
	elif input "$1" "install";             then install
#	elif input "$1" "<command>" "<alt>";   then <function_name>	
	else show_help
	fi
}

####  List of commands and their function (called by `show_help`).
function help_list
{
	help_item "short"       "See list of command short-forms"
	help_item "update"      "Update to the latest version"
	help_item "version"     "Print the version"
#	help_item "<command>"   "<description>"
}

####  List of commands and their shortform name (called by `show_short`).
function short_list
{
	help_item "version"     "v"
	help_item "help"        "h"
#	help_item "<command>"   "<shortform>"
}

####  Do something when no arguments are provided.
function no_args
{
	##  placeholder example: interactive list of color options
	menu 0 \
		" normal text " \
		" $(red "red text") " \
		" $(yellow "yellow text") " \
		" $(green "green text") " \
		" $(teal "teal text") " \
		" $(blue "blue text") " \
		" $(purple "purple text") " \
		" $(dim "dim text") " \
		" $(dim "$(red "dim red text")") " \
		" $(dim "$(yellow "dim yellow text")") " \
		" $(dim "$(green "dim green text")") " \
		"$(teal "$(invert " background teal text ")")" \
		"$(blue "$(invert " background blue text ")")" \
		"$(purple "$(invert " background purple text ")")"
	
	##  run after selection
	printf "\n$(red "N")$(yellow "i")$(green "c")$(teal "e") $(blue "c")$(purple "h")$(red "o")$(yellow "i")$(green "c")$(teal "e")\n\n"
}


###############################################################################
####  Utility functions
###############################################################################

####  Prompts the user for input, and returns their response.
####  Usage: `var=$(get_response)`
function get_response
{
	read -p "" -r
	printf "$REPLY"
}

####  Inverts text (the background will be the foreground color, & visa versa).
####  Note: all pre-existing colors are stripped from the input. If you need
####  red-backgrounded text, use `red "$(invert "$text")"` (rather than the
####  other way around).
function invert
{
	printf "\033[7m$(remove_colors "$1")\033[0m"
}

####  Dims the color of the text.
function dim
{
	printf "\033[2m$1\033[0m"
}

####  Colors the text red.
function red
{
	printf "\033[1;31m$1\033[0m"
}

####  Colors the text green.
function green
{
	printf "\033[1;32m$1\033[0m"
}

####  Colors the text yellow.
function yellow
{
	printf "\033[1;33m$1\033[0m"
}

####  Colors the text blue.
function blue
{
	printf "\033[1;34m$1\033[0m"
}

####  Colors the text purple.
function purple
{
	printf "\033[1;35m$1\033[0m"
}

####  Colors the text teal.
function teal
{
	printf "\033[1;36m$1\033[0m"
}

####  Removes color codes from inputted string.
function remove_colors
{
	echo "$1" | sed -E "s/[[:cntrl:]]\[(1;31|1;32|1;33|1;34|1;35|1;36|0|2|7)m//g"
}

####  Print interactable menu of items. Navigatable with the arrow
####  keys, press <enter> or <space> to select.
####
####  Usage: menu <index> <item 1> <item 2> ... <item n>
####  Where: each <item> is an option & <index> is currently selected
####  Returning: exit code representing the user's selection
function menu
{
	## set start position
	start_pos=$(get_pos)
	##  if not enough lines remain, output will push up cursor
	##  preform more complex cursor save/return
	lines_remaining=$(($(tput lines) - $start_pos))
	if [ $(($(tput lines) - $start_pos)) -lt $(($# + 3)) ]; then
		newlines=$(echo "$@" | wc -l)
		list_item_total=$(($# + $newlines))
		start_pos=$(($(tput lines) - $list_item_total))
	fi

	selected="$1"
	length=$(($# - 2))
	shift
	
	while true; do
		
		index=0

		##  print all items
		for item in "$@"; do

			if [ "$index" = "$selected" ]; then 
				##  invert if selected
				printf "$(invert "$item")\n"
			else
				printf "${item}\n"
			fi

			index=$(($index+1))
		done

		##  handle input
		while true; do
			read -rsn1 esc
			if [ "$esc" == $'\033' ]; then
				read -sn1 bra
				read -sn1 typ
			elif [ "$esc" == "" ]; then
				##  enter
				return $selected
			fi
			if [ "$esc$bra$typ" == $'\033'[A ]; then
				##  move up
				selected=$(($selected - 1))
				if [ "$selected" -lt "0" ]; then
					##  if at zero, loop around to end
					selected="$length"
				fi
				break
			elif [ "$esc$bra$typ" == $'\033'[B ]; then
				##  move down
				selected=$(($selected + 1))
				if [ "$selected" -gt "$length" ]; then
					##  if at end, loop back around
					selected=0
				fi
				break
			fi
		done

		clear_to $start_pos
		echo
	done
}

####  Returns current cursor position (row), by printing it (so you
####  can capture it with `var=$(get_pos)`. Can be used in conjunction
####  with `clear_to` to "soft clear" back to the current position.
####
####  NOTE: this can get messed up if you're printing more rows than are
####  currently availible, pushing the position up. Can be remedied with
####  something like (from the `menu` function):
####  ```
####  	start_pos=$(get_pos)  # get position
####  	lines_remaining=$(($(tput lines) - $start_pos))
####  	##  if we're printing each argument on a newline, the total lines
####  	##  printed will be the number of arguments (plus all the newlines
####  	##  inside of them). Get the number of lines:
####  	newlines_found=$(echo "$@" | wc -l)
####  	total_lines=$(($# + $newlines_found))
####  	if [ $(($(tput lines) - $start_pos)) -lt $total_lines ]; then
####  		start_pos=$(($(tput lines) - $total_lines))
####  	fi
####  ```
function get_pos
{
	exec < /dev/tty
	oldstty=$(stty -g)
	stty raw -echo min 0
	echo "\033[6n" > /dev/tty
	IFS=';' read -r -d R -a pos
	stty $oldstty
	echo $((${pos[0]:2} - 1))
}

####  Clears console to the inputted line number. Use in conjunction
####  with `get_pos`.
function clear_to
{
	tput cup $1 0
}

####  Handles input command matching.
####  First argument is the user's input, the following arguments are
####  the commands to match it against. Allows you to provide synonymous
####  and short-form command options (i.e. "update", "upgrade" "u"), as 
####  well as optional hyphen-syntax ("u", "-u", "--u").
function input
{
	prefix="-"
	argument="$1"
	shift

	for var in "$@"; do
		if [ "$var" = "$argument" ] ||
		   [ "${prefix}${var}" = "$argument" ] ||
		   [ "${prefix}${prefix}${var}" = "$argument" ]; then 
			return 0
		fi
	done

	return 1
}

####  Prints an item in the help menu, properly indented. First param
####  should be the command name, second is the description.
function help_item
{
	printf "  $1\t\t$2\n"
}

####  Prints the program's Help page, listing the availible commands and 
####  their functions.
function show_help
{
	echo
	print_hr
	echo "  ${program} v${version}  --  Help"
	print_hr
	printf "\n  ${program} [command] \t description \n\n"
	help_list
	printf "\n\n"
}

####  Prints the short-form versions of the availible commands.
function show_short
{
	echo
	print_hr
	echo "  ${program} v${version}  --  Short-Form Commands"
	print_hr
	printf "\n  [command] \t\t [short-form] \n\n"
	short_list
	printf "\n\n"
}

####  Prints a horizontal rule (of "=" characters) across the width of
####  the terminal's screen.
function print_hr
{
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

####  Prints current version of script.
function print_version
{
	echo "${program} v${version}"
}

####  Updates program to newest version, pulling the current code directly
####  from the source_url (at the top of the file).
function update
{
	echo "Downloading newest version..."
	## curls source with current date added (to avoid old cached versions)
	HTTP_CODE=$(curl --write-out "%{http_code}" -H 'Cache-Control: no-cache' "${source_url}?$(date +%s)" -o "${program}-temp.sh")

	if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then 
		printf "\nDownload failed. Response code = ${HTTP_CODE}\n"
		rm -f "${program}-temp.sh"
		exit 1
    fi

	mv -f "${program}-temp.sh" "${program}.sh"
	chmod +x "${program}.sh"
	printf "\nFinished downloading!\n"
	echo
	printf "${program} v${version} => "
	sh "${program}.sh" version
	printf "\nInstall new version in '/usr/local/bin/'?\n"
	read -p "(y/n):  " -r
	if   [[ $REPLY =~ ^[Yy]$ ]]; then install
	elif [[ $REPLY =~ ^[Nn]$ ]]; then echo "Ok, update is downloaded but not installed."
	else echo "Input '${REPLY}' not recognized. Update is downloaded but will not be installed. Run '${program} install' to finish installing."
	fi
}

####  Installs the script as an executable in /usr/local/bin/
####  TODO: make compatible w/ linux, etc
function install
{
	echo "Installing at /usr/local/bin/${program} ..."
	mv -f "${program}.sh" "/usr/local/bin/${program}"
	chmod +x "/usr/local/bin/${program}"
	echo "Installation complete. Try running '${program} version'"
}

#### Start the script; handle the user's input.
handle_input $@