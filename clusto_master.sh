#!/bin/bash

mkdir above_4

cp input_data/inplantavsinvitro.csv above_4

cp input_data/Penicillium_sp._X.gff3 above_4

cd above_4

## Convert our csv file to a tab-delimited one. 

sed 's/\,/\t/g' inplantavsinvitro.csv > inplantavsinvitro.txt

## Write an if loop that if the LFC (column 2) is above a specified value, then pull the ID (column 1) to a new txt file for grepping against gff3 file. 

while read LINE; do

awk '{ minimumLFC=4 ;

if ($2 >= minimumLFC)

    print $1 > "selective_geneids.txt"

}'

done<inplantavsinvitro.txt

## Use this new selective gene id file to modify a gff3 to only contain genes regulated above or below the specified spot. 

grep -f selective_geneids.txt Penicillium_sp._X.gff3 > Penicillium_sp._X_above_four.gff3.txt

## Then grep it down to only mRNA 

grep "mRNA" Penicillium_sp._X_above_four.gff3.txt > Penicillium_sp._X_above_four_onlymrna.gff3.txt

## Then we need to separate them into contigs. 

mkdir passed_to_awk

## for loop to do the separating, BUG; works but cant get the $i in output file name to be in middle of the file name where I want it to be. 

for i in {1..8};

do

    grep 'tig0000000'$i Penicillium_sp._X_above_four_onlymrna.gff3.txt > passed_to_awk/Penicillium_sp._X_above_four_tig$i

done

## Step X. Modify gff3 to remove unneeded data and calculate mid-point of gene. 

for FILE in passed_to_awk/*;

do

    awk -i inplace '{print $9, ($4+$5)/2}' $FILE

done 

## The final selected-gene-location files will be in the passed_to_awk directory for use. 

cd passed_to_awk

## Then use this to run the window code and output to a new file 

python3 ~/inspector_clusto/testing/scripts/clusto_window_looping.py > ../clusters.txt
