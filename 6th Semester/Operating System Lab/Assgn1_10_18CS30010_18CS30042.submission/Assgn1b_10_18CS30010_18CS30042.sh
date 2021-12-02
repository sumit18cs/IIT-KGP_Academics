# ! /bin/bash
cd 1.b.files
for entry in *
do
  sort -nr -o $entry $entry
done

mkdir 1.b.files.out

for entry in *; do
	if [[ -f $entry ]]
	then
		cp $entry 1.b.files.out
	fi
done

mv 1.b.files.out ../

for entry in *; do
	cat $entry >> ../1.b.out.txt
done
cd ..
sort -nr -o 1.b.out.txt 1.b.out.txt