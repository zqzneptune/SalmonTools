#!/usr/bin/env bash

print_usage_and_exit () {
    echo "Usage: $0 [-s =1.8.0 Salomn Version] [-h <Gencode Human version>] [-m <Gencode Mouse version>]"
    exit 1
}

while getopts s:h:m: flag
do
    case "${flag}" in
        s) VERSALMON=${OPTARG};;
        h) VERGENCODEH=${OPTARG};;
        m) VERGENCODEM=${OPTARG};;
    esac
done

# Required arguments
if [ -z "${VERSALMON}" -o -z "${VERGENCODEH}" -o -z "${VERGENCODEM}" ];then
    echo "Error: missing required argument(s)"
    print_usage_and_exit
fi


echo "Salmon Version: ${VERSALMON}";
echo "Gencode Human Version: ${VERGENCODEH}";
echo "Gencode Mouse Version: M${VERGENCODEM}";


#VERSALMON=1.8.0 # Salmon Version

SHDECOY=generateDecoyTranscriptome.sh
if [ ! -f "${SHDECOY}" ]; then
    curl -O https://raw.githubusercontent.com/zqzneptune/SalmonTools/master/scripts/generateDecoyTranscriptome.sh
fi

MASHMAP=mashmap-Linux64-v2.0/mashmap
if [ ! -f "${MASHMAP}" ]; then
    wget -c https://github.com/marbl/MashMap/releases/download/v2.0/mashmap-Linux64-v2.0.tar.gz
    tar xzvf mashmap-Linux64-v2.0.tar.gz
fi

BEDTOOLS=bedtools.static.binary
if [ ! -f "${BEDTOOLS}" ]; then
    wget -c https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary
    chmod 755 bedtools.static.binary
fi

SALMON=salmon-${VERSALMON}_linux_x86_64/bin/salmon
if [ ! -f "${SALMON}" ]; then
    wget -c https://github.com/COMBINE-lab/salmon/releases/download/v${VERSALMON}/salmon-${VERSALMON}_linux_x86_64.tar.gz
    tar xzvf salmon-${VERSALMON}_linux_x86_64.tar.gz
fi



################### Gencode Human ##############
# VERGENCODEH=36 # Gencode Version


DIRINDEXH=index/${VERSALMON}/human_gencode${VERGENCODEH}


FNTXFAH=gencode.v${VERGENCODEH}.transcripts.fa
FNTXGTFH=gencode.v${VERGENCODEH}.annotation.gtf

mkdir -p ${DIRINDEXH}
mkdir -p ${DIRINDEXH}\_k15


if [ ${VERGENCODEH} -ge 20 ]; then
    FNGNEOME=GRCh38.primary_assembly.genome.fa
else
    echo "Gencode too old"
    exit 1
fi

if [ -f "${FNGNEOME}" ]; then
    echo "${FNGNEOME} exists."
else 
    echo "${FNGNEOME} does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${VERGENCODEH}/${FNGNEOME}.gz
    gunzip ${FNGNEOME}.gz
fi

if [ -f "${FNTXFAH}" ]; then
    echo "${FNTXFAH} exists."
else
    echo "${FNTXFAH}  does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${VERGENCODEH}/${FNTXFAH}.gz
    gunzip ${FNTXFAH}.gz
fi

if [ -f "${FNTXFAH}" ]; then
    cat ${FNTXFAH}| grep "^>"|sed 's|[<>,]||g' > ${DIRINDEXH}/transcripts.txt
    gzip ${DIRINDEXH}/transcripts.txt
    cat ${FNTXFAH}| grep "^>"|sed 's|[<>,]||g' > ${DIRINDEXH}\_k15/transcripts.txt
    gzip ${DIRINDEXH}\_k15/transcripts.txt
fi

if [ -f "${FNTXGTFH}" ]; then
    echo "${FNTXGTFH} exists."
else
    echo "${FNTXGTFH}  does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_$VERGENCODEH/${FNTXGTFH}.gz
    gunzip ${FNTXGTFH}.gz
fi

bash ${SHDECOY} -j 8 -b $BEDTOOLS -m $MASHMAP -a ${FNTXGTFH} -g ${FNGNEOME} -t ${FNTXFAH} -o $DIRINDEXH

$SALMON index -t $DIRINDEXH/gentrome.fa -d $DIRINDEXH/decoys.txt -i $DIRINDEXH --gencode

$SALMON index -t $DIRINDEXH/gentrome.fa -d $DIRINDEXH/decoys.txt -i $DIRINDEXH\_k15 -k 15 --gencode


###################### Mouse Gencode ##################
VERGENCODEM=29

DIRINDEXM=index/${VERSALMON}/mouse_gencodeM${VERGENCODEM}
mkdir -p ${DIRINDEXM}
mkdir -p ${DIRINDEXM}\_k15

FNTXFAM=gencode.vM${VERGENCODEM}.transcripts.fa
FNTXGTFM=gencode.vM${VERGENCODEM}.annotation.gtf

if [ ${VERGENCODEM} -ge 26 ]; then
    FNGNEOMEM=GRCm39.primary_assembly.genome.fa
elif [ ${VERGENCODEM} -ge 2 ]; then
    FNGNEOMEM=GRCm38.primary_assembly.genome.fa
else
    echo "Gencode too old"
    exit 1
fi

if [ -f "${FNGNEOMEM}" ]; then
    echo "${FNGNEOMEM} exists."
else 
    echo "${FNGNEOMEM} does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M${VERGENCODEM}/${FNGNEOMEM}.gz
    gunzip ${FNGNEOMEM}.gz
fi

if [ -f "${FNTXFAM}" ]; then
    echo "${FNTXFAM} exists."
else
    echo "${FNTXFAM}  does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M${VERGENCODEM}/${FNTXFAM}.gz
    gunzip ${FNTXFAM}.gz
fi

if [ -f "${FNTXFAM}" ]; then
    cat ${FNTXFAM}| grep "^>"|sed 's|[<>,]||g' > ${DIRINDEXM}/transcripts.txt
    gzip ${DIRINDEXM}/transcripts.txt
    cat ${FNTXFAM}| grep "^>"|sed 's|[<>,]||g' > ${DIRINDEXM}\_k15/transcripts.txt
    gzip ${DIRINDEXM}\_k15/transcripts.txt
fi

if [ -f "${FNTXGTFM}" ]; then
    echo "${FNTXGTFM} exists."
else
    echo "${FNTXGTFM}  does not exist ... start downloading ..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M$VERGENCODEM/${FNTXGTFM}.gz
    gunzip ${FNTXGTFM}.gz
fi

sh ${SHDECOY} -j 8 -b $BEDTOOLS -m $MASHMAP -a ${FNTXGTFM} -g ${FNGNEOMEM} -t ${FNTXFAM} -o $DIRINDEXM

$SALMON index -t $DIRINDEXM/gentrome.fa -d $DIRINDEXM/decoys.txt -i $DIRINDEXM --gencode

$SALMON index -t $DIRINDEXM/gentrome.fa -d $DIRINDEXM/decoys.txt -i $DIRINDEXM\_k15 -k 15 --gencode
