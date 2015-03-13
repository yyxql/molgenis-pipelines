#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string mergeSamFilesJar
#string mergedBam
#string mergedBamIdx
#string tempDir
#list inputMergeBam
#list inputMergeBamIdx
#string tmpDataDir
#string project


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "mergeSamFilesJar: ${mergeSamFilesJar}"
echo "mergedBam: ${mergedBam}"
echo "mergedBamIdx: ${mergedBamIdx}"
echo "tempDir: ${tempDir}"
for bam in "${inputMergeBam[@]}"
do
  echo "bam: $bam"
done
for bamIdx in "${inputMergeBamIdx[@]}"
do
  echo "bamIdx: $bamIdx"
done

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

makeTmpDir ${mergedBam}
tmpMergedBam=${MC_tmpFile}

makeTmpDir ${mergedBamIdx}
tmpMergedBamIdx=${MC_tmpFile}

#Get aligned BAM and idx file
for getBam in "${inputMergeBam[@]}"
do
  getFile $getBam
done
for getBamIdx in "${inputMergeBamIdx[@]}"
do
  getFile $getBamIdx
done

#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
for bamFile in "${inputMergeBam[@]}"
do
	array_contains INPUTS "INPUT=$bamFile" || INPUTS+=("INPUT=$bamFile")    # If bamFile does not exist in array add it
done

java -XX:ParallelGCThreads=4 -jar -Xmx6g $PICARD_HOME/${mergeSamFilesJar} \
${INPUTS[@]} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
USE_THREADING=true \
TMP_DIR=${tempDir} \
MAX_RECORDS_IN_RAM=6000000 \
VALIDATION_STRINGENCY=LENIENT \
OUTPUT=${tmpMergedBam} \

echo -e "\nMergedBam finished succesfull. Moving temp files to final.\n\n"
mv ${tmpMergedBam} ${mergedBam}
mv ${tmpMergedBamIdx} ${mergedBamIdx}
putFile "${mergedBam}"
putFile "${mergedBamIdx}"