# Building Salmon index from Gencode transcripts

wget https://raw.githubusercontent.com/zqzneptune/SalmonTools/master/buildGencodeSalmonIndex.sh

bash buildGencodeSalmonIndex.sh -s 1.8.0 -h 40 -m 29

*-s* salmon version, *-h* Human Gencode version, *-m* Mouse Gencode version

A folder *index* will be created in the current folder with all the built indeices.
