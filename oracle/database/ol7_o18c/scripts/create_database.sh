pdbName=$1
allPasswords=$2

dbca -silent -createDatabase \
-responseFile NO_VALUE \
-gdbName ${ORACLE_SID} \
-sid ${ORACLE_SID} \
-databaseConfigType SI \
-createAsContainerDatabase true \
-numberOfPDBs 1 \
-pdbName ${pdbName} \
-useLocalUndoForPDBs true \
-pdbAdminPassword ${allPasswords} \
-templateName ${ORACLE_HOME}/assistants/dbca/templates/General_Purpose.dbc \
-sysPassword ${allPasswords} \
-systemPassword ${allPasswords} \
-runCVUChecks FALSE \
-omsPort 0 \
-olsConfiguration false \
-datafileJarLocation ${ORACLE_HOME}/assistants/dbca/templates/ \
-datafileDestination /u05/oradata/${ORACLE_SID}/ \
-storageType FS \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-registerWithDirService false \
-listeners LISTENER \
-initParams undo_tablespace=UNDOTBS1,sga_target=2312MB,db_block_size=8192BYTES,nls_language=AMERICAN,dispatchers="\(PROTOCOL TCP\) \(SERVICE {ORACLE_SID}XDB\)",diagnostic_dest=${ORACLE_BASE},remote_login_passwordfile=EXCLUSIVE,db_create_file_dest=/u05/oradata/${ORACLE_SID}/,db_create_online_log_dest_2=/u04,db_create_online_log_dest_1=/u03,audit_file_dest=${ORACLE_BASE}/admin/${ORACLE_SID}/adump,processes=300,pga_aggregate_target=771MB,nls_territory=AMERICA,local_listener=LISTENER_${ORACLE_SID},open_cursors=300,compatible=18.0.0,db_name=${ORACLE_SID},audit_trail=db \
-sampleSchema false \
-databaseType MULTIPURPOSE \
-automaticMemoryManagement false \
-totalMemory 0

echo "##########################################################################################################################"
echo "Set the PDB to auto-start." `date`
echo "##########################################################################################################################"
sqlplus / as sysdba <<EOF
alter pluggable database all save state;
exit;
EOF
