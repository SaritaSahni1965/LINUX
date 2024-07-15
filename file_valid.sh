#!/bin/ksh
###################################################################
#
# Script to check and send mail alerts for below scenarios:
# 1. Files older than a day in $INDIR diretory  - Existing
# 2. EBS files older than a day in $FTPDIR directory - New
# 3. Germany files older than a day in $FTPDIR/de/ directory - New
#
###################################################################

# Create temporary file with current PID to store the filenames
msgfile=rdmmailmsg$$
noFF_msg="File Not Found"
TodayDate=`date +%y%m%d`

trap '
     echo "\n\t- INTERUPT RECEIVED\n"
     rm -f ${msgfile}
     exit 0
    ' HUP INT QUIT TERM

# Declare Variables
ENV=`awk -F '~' '{ print toupper($2) }' $PRFDIR/dsprojects.list.sf | cut -d "_" -f 2`
DATE=`date "+%Y-%m-%d %H:%M:%S"`

# Find all files in $INDIR older than a day
filecount=$(find $INDIR/N* -name  "*" -mtime +0  2> /dev/null | grep -v $TodayDate | wc -l)
filelist=$(find $INDIR/N* -name  "*" -mtime +0 | grep -v $TodayDate | sed "s/.*\///")

# Find EBS files in $FTPDIR older than a day
ebsfilecount=$(find $FTPDIR/N* -name "N872*" -o -name "N457*" -mtime +0  2> /dev/null | grep -v $TodayDate | wc -l)
ebsfilelist=$(find $FTPDIR/N* -name "N872*" -o -name "N457*" -mtime +0 | grep -v $TodayDate | sed "s/.*\///")

# Find Germany files in $FTPDIR/de older than a day
defilecount=$(find $FTPDIR/de/ -name  "*" -mtime +0  2> /dev/null | grep -v $TodayDate | wc -l)
defilelist=$(find $FTPDIR/de/ -name  "*" -mtime +0 | grep -v $TodayDate | sed "s/.*\///")

# Load all filenames into temporary file
if [ "$filecount" != "0" ];  then
        echo "--------------------------------------------------------------------------------------" >> ${msgfile}
        echo "            Summary of Batches in Input Directory Waiting to Process"                   >> ${msgfile}
        echo "--------------------------------------------------------------------------------------" >> ${msgfile}
        for list in $filelist
        do
                echo $list >> ${msgfile}
        done
        # Send contents in temporary file to email list
        cat ${msgfile} | mail -s " $ENV -  Summary of Batches in Input Directory Waiting to Process $DATE " ${sendto:=`cat ${PRFDIR}/rasp.email.list.sf`}
else
         echo "1 day older $noFF_msg in $INDIR"
fi

# Load all EBS filenames into temporary file
if [ "$ebsfilecount" != "0" ];  then
        echo "--------------------------------------------------------------------------------------" > ${msgfile}
        echo "            Summary of EBS Batches in FTP Directory Waiting to Process"                 >> ${msgfile}
        echo "--------------------------------------------------------------------------------------" >> ${msgfile}
        for list in $ebsfilelist
        do
                echo $list >> ${msgfile}
        done
        # Send contents in temporary file to email list
        cat ${msgfile} | mail -s " $ENV -  Summary of EBS Batches in FTP Directory Waiting to Process $DATE " ${sendto:=`cat ${PRFDIR}/rasp.email.list.sf`}
else
         echo "1 day old EBS $noFF_msg in $FTPDIR"
fi

# Load all Germany filenames into temporary file
if [ "$defilecount" != "0" ];  then
        echo "--------------------------------------------------------------------------------------" > ${msgfile}
        echo "            Germany Batches Waiting to Process"                                         >> ${msgfile}
        echo "--------------------------------------------------------------------------------------" >> ${msgfile}
        for list in $defilelist
        do
                echo $list >> ${msgfile}
        done
        # Send contents in temporary file to email list
        cat ${msgfile} | mail -s " $ENV -  Germany Batches Waiting to Process $DATE " ${sendto:=`cat ${PRFDIR}/rasp.email.list.sf`}
else
         echo "1 day old Germany $noFF_msg in $FTPDIR/de/"
fi

# Remove the temporary file
rm -f ${msgfile}

exit 0

