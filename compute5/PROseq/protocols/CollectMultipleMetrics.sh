#MOLGENIS walltime=23:59:00 mem=4gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string picardVersion
#string RVersion
#string reads1FqGz
#string collectMultipleMetricsDir
#string collectMultipleMetricsPrefix
#string onekgGenomeFasta
#string maskedBamSorted
#string sortedBai
#string toolDir

#load modules
${stage} picard/${picardVersion}

#Check modules
${checkStage}

mkdir -p ${collectMultipleMetricsDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

insertSizeMetrics=""
#if [ ${#reads2FqGz} -ne 0 ]; then
#	insertSizeMetrics="PROGRAM=CollectInsertSizeMetrics"
#fi

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle

echo java -jar -Xmx4g -XX:ParallelGCThreads=4 ${toolDir}picard/${picardVersion}/CollectMultipleMetrics.jar \
        I=${maskedBamSorted} \
        O=${collectMultipleMetricsPrefix} \
        R=${onekgGenomeFasta} \
        PROGRAM=CollectAlignmentSummaryMetrics \
        PROGRAM=QualityScoreDistribution \
        PROGRAM=MeanQualityByCycle \
        $insertSizeMetrics \
        TMP_DIR=${collectMultipleMetricsDir}
if java -jar -Xmx4g -XX:ParallelGCThreads=4 ${toolDir}picard/${picardVersion}/CollectMultipleMetrics.jar \
 I=${maskedBamSorted} \
 O=${collectMultipleMetricsPrefix} \
 R=${onekgGenomeFasta} \
 PROGRAM=CollectAlignmentSummaryMetrics \
 PROGRAM=QualityScoreDistribution \
 PROGRAM=MeanQualityByCycle \
 $insertSizeMetrics \
 TMP_DIR=${collectMultipleMetricsDir}
then
 echo "returncode: $?";
 putFile ${collectMultipleMetricsPrefix}.alignment_summary_metrics
 putFile ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics
 putFile ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf
 putFile ${collectMultipleMetricsPrefix}.quality_distribution_metrics
 putFile ${collectMultipleMetricsPrefix}.quality_distribution.pdf
cd ${collectMultipleMetricsDir}
bname=$(basename ${collectMultipleMetricsPrefix})
md5sum ${bname}.quality_distribution_metrics > ${bname}.quality_distribution_metrics.md5
md5sum ${bname}.alignment_summary_metrics > ${bname}.alignment_summary_metrics.md5
md5sum ${bname}.quality_by_cycle_metrics > ${bname}.quality_by_cycle_metrics.md5
md5sum ${bname}.quality_by_cycle.pdf > ${bname}.quality_by_cycle.pdf.md5
md5sum ${bname}.quality_distribution.pdf > ${bname}.quality_distribution.pdf.md5
cd -
echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi


echo "## "$(date)" ##  $0 Done "
