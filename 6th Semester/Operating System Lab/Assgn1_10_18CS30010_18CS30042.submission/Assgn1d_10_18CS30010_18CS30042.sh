#! /bin/bash

read file_name

if [[ -f $file_name ]]; then
	case $file_name in
		*.tar.bz2)
			tar xjf $file_name;;
		*.tar.gz)
			tar xzf $file_name;;
		*.bz2)
			bunzip2 $file_name;;
		*.rar)
			rar $file_name;;
		*.gz)
			gunzip $file_name;;	
		*.tar)
			tar xf $file_name;;
		*.tbz2)
			tar xjf $file_name;;
		*.tgz)
			tar xzf $file_name;;
		*.zip)
			unzip $file_name;;
		*.Z)
			uncompress $file_name;;
		*.7z)
			7z x $file_name;;
		*)
			echo "Unknown file format:	cannot	extract"

	esac
else
	echo "$file_name does not exit"
fi