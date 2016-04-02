#!/bin/bash
input="./ip-and-hostname"
linenum=2
cp hosts.template hosts
while IFS= read -r var
do
	ed hosts <<TEXT
$linenum
i
$var
.
w
q
TEXT
done < "$input"
linenum=$((linenum+1))
cat ./hosts
