echo "******************************************************************************"
echo "Unzip File." `date`
echo "******************************************************************************"

cd ${ORACLE_HOME}
unzip -oq ${SOFTWARE_DIR}/${SOFTWARE_FILE}

echo "******************************************************************************"
echo "Install Oracle." `date`
echo "******************************************************************************"

# Details about the following parameters can be found at ${ORACLE_HOME}/install/response/db_install.rsp
${ORACLE_HOME}/runInstaller -ignorePrereq -waitforcompletion -silent \
-responseFile ${ORACLE_HOME}/install/response/db_install.rsp \
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v18.0.0 \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=${ORACLE_GROUP} \
INVENTORY_LOCATION=${ORACLE_INVENTORY} \
ORACLE_BASE=${ORACLE_BASE}/ \
ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=oper \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
oracle.install.db.CLUSTER_NODES= \
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE \
oracle.install.db.config.starterdb.globalDBName= \
oracle.install.db.config.starterdb.SID= \
oracle.install.db.ConfigureAsContainerDB=false \
oracle.install.db.config.PDBName= \
oracle.install.db.config.starterdb.characterSet= \
oracle.install.db.config.starterdb.memoryOption=false \
oracle.install.db.config.starterdb.memoryLimit= \
oracle.install.db.config.starterdb.installExampleSchemas=false \
oracle.install.db.config.starterdb.password.ALL= \
oracle.install.db.config.starterdb.password.SYS= \
oracle.install.db.config.starterdb.password.SYSTEM= \
oracle.install.db.config.starterdb.password.DBSNMP= \
oracle.install.db.config.starterdb.password.PDBADMIN= \
oracle.install.db.config.starterdb.managementOption=DEFAULT \
oracle.install.db.config.starterdb.omsHost= \
oracle.install.db.config.starterdb.omsPort=0 \
oracle.install.db.config.starterdb.emAdminUser= \
oracle.install.db.config.starterdb.emAdminPassword= \
oracle.install.db.config.starterdb.enableRecovery=false \
oracle.install.db.config.starterdb.storageType= \
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation= \
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation= \
oracle.install.db.config.asm.diskGroup= \
oracle.install.db.config.asm.ASMSNMPPassword=
