# ! /bin/bash
read file_name col
col=$((col-1))

while IFS= read -r a; do
	cnt=0
	str=("F")
	for i in $a; do
		old[cnt]=$i
		if [[ $cnt -eq $col ]]; then

			i="$(tr [A-Z] [a-z] <<< "$i")"
			echo $i >> temp.txt
		fi

		str[cnt]=$i
		cnt=$((cnt+1))
	done
	echo ${str[@]} >> ntest.txt

done<$file_name

cp ntest.txt $file_name

col=$((col+1))
cat "temp.txt" | sort | uniq -c | sort -nr | awk '{print $2, $1}' > 1c_output_${col}_column.freq

rm temp.txt ntest.txt 
