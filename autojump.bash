#Copyright Joel Schaerer 2008, 2009
#This file is part of autojump

#autojump is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#autojump is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with autojump.  If not, see <http://www.gnu.org/licenses/>.

#This shell snippet sets the prompt command and the necessary aliases

MODE_AUTO=0

_autojump() 
{
        local cur
        cur=${COMP_WORDS[*]:1}
        while read i
        do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done  < <(autojump --bash --completion $cur)
}

complete -o dirnames -F _autojump cd
complete -F _autojump autojump

data_dir=$([ -e ~/.local/share ] && echo ~/.local/share || echo ~)
export AUTOJUMP_HOME=${HOME}

if [[ "$data_dir" = "${HOME}" ]]
then
    export AUTOJUMP_DATA_DIR=${data_dir}
else
    export AUTOJUMP_DATA_DIR=${data_dir}/autojump
fi

if [ ! -e "${AUTOJUMP_DATA_DIR}" ]
then
    mkdir "${AUTOJUMP_DATA_DIR}"
    mv ~/.autojump_py "${AUTOJUMP_DATA_DIR}/autojump_py" 2>>/dev/null #migration
    mv ~/.autojump_py.bak "${AUTOJUMP_DATA_DIR}/autojump_py.bak" 2>>/dev/null
    mv ~/.autojump_errors "${AUTOJUMP_DATA_DIR}/autojump_errors" 2>>/dev/null
fi

alias jumpstat="autojump --stat"
alias cd="j"

function j {    
    new_path=""
    jump=0
    error=0

    if [ $# -eq 0 ] ; then
	\cd >/dev/null
	new_path="$(pwd -P)"
    else
	case "$1" in
	    "-")
		\cd "$1" && new_path="$(pwd -P)" || error=1
		;;
	    "\.\.*")
		\cd "$1" && new_path="$(pwd -P)" || error=1
		;;
	    "/*")
		\cd "$1" && new_path="$(pwd -P)" || error=1
		;;
	    *)
		jump=1
		new_path="$(autojump $@)"
		;;
	    esac
    fi

    [ $error -eq 1 ] && return
    
    if [ -n "$new_path" ]; then 
	if [ $jump = 1 ] ; then
	    \cd "$new_path" > /dev/null || error=1
	    if [ $error -eq 0 ] ; then
		if [ $MODE_AUTO -eq 1 ] ; then
		    echo -e "\\033[31m${new_path}\\033[0m"
		    autojump -a "$(pwd -P)" >/dev/null 2>>${AUTOJUMP_DATA_DIR}/.autojump_errors || echo "${new_path}"
		else
		    echo "$new_path"
		fi
	    fi
	fi
    else
	[ -d "$1" ] && \cd "$1" && [ $MODE_AUTO -eq 1 ] && autojump -a "$(pwd -P)" >/dev/null 2>>${AUTOJUMP_DATA_DIR}/.autojump_errors
    fi    
}
