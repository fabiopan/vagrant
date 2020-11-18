echo "##########################################################################################################################"
echo "Environment Variables" `date`
echo "##########################################################################################################################"
export OS_SHM_SIZE=4G
export ORACLE_USER=oracle
export ORACLE_GROUP=oinstall
export ORACLE_BASE=/u01/app/${ORACLE_USER}
export ORACLE_HOME=${ORACLE_BASE}/product/18.0.0/dbhome_1
export ORACLE_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=SAMERICA
export SOFTWARE_DIR=/u01/software
export SOFTWARE_FILE=V978967-01.zip
export PDB_NAME=BRAZIL
export ALL_PASSWORDS=Ora123clE

echo "##########################################################################################################################"
echo "# Check If Oracle Software Zip File exists In The Default Software directory." `date`                                   "#"  
echo "##########################################################################################################################"
if [[ ! -f "/vagrant/software/${SOFTWARE_FILE}" ]] ; then
    echo "File "/vagrant/software/${SOFTWARE_FILE}" is not there, aborting."
    exit
fi

echo "##########################################################################################################################"
echo "# Setup disks." `date`                                                                                                  "#"
echo "##########################################################################################################################"
function prepare_disk
{
  MOUNT_POINT=$1
  DISK_DEVICE=$2

  echo "##########################################################################################################################"
  echo "# Setup ${MOUNT_POINT} disk." `date`                                                                                    "#"
  echo "##########################################################################################################################"
  # New partition for the whole disk.
  echo -e "n\np\n1\n\n\nw" | fdisk ${DISK_DEVICE}
  
  # Add file system.
  mkfs.xfs -f ${DISK_DEVICE}1
  
  # Mount it.
  UUID=`blkid -o export ${DISK_DEVICE}1 | grep UUID | grep -v PARTUUID`
  mkdir ${MOUNT_POINT}
  echo "${UUID}  ${MOUNT_POINT}    xfs    defaults 1 2" >> /etc/fstab
  mount ${MOUNT_POINT}

}

prepare_disk /u01 /dev/sdb
prepare_disk /u02 /dev/sdc
prepare_disk /u03 /dev/sdd
prepare_disk /u04 /dev/sde
prepare_disk /u05 /dev/sdf

echo "##########################################################################################################################"
echo "# Setup Shared Memory" `date`                                                                                           "#"
echo "##########################################################################################################################"

# Verify that shared memory
echo `df -h /dev/shm`

# Mount it.
echo "/dev/mapper/vg_main-lv_shm /dev/shm                xfs     defaults,size=${OS_SHM_SIZE},rw,exec        0 0" >> /etc/fstab
mount -o remount /dev/shm

# Verify that shared memory
echo `df -h /dev/shm`

echo "##########################################################################################################################"
echo "# Setup Network Time Protocol" `date`                                                                                   "#"
echo "##########################################################################################################################"
function ntp_setup
{
PATTERN='OPTIONS="-g"'
REPLACEMENT='OPTIONS="-x -u ntp:ntp -p \/var\/run\/ntpd.pid -g"'
yum install -y ntp
systemctl start ntpd.service
systemctl enable ntpd.service
sed -i 's/'"$PATTERN"'/'"$REPLACEMENT"'/' /etc/sysconfig/ntpd
}

ntp_setup

echo "##########################################################################################################################"
echo "# Setup OS Packages Required" `date`                                                                                    "#"
echo "##########################################################################################################################"

yum install -y \
xorg-x11-apps \
xorg-x11-utils \
xauth \
unzip

echo "##########################################################################################################################"
echo "# Setup Swap Area" `date`                                                                                               "#"
echo "##########################################################################################################################"

echo `free -m`
dd if=/dev/zero of=/swapfile bs=1024 count=8388608
chown root:root /swapfile
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab
echo `free -m`

echo "##########################################################################################################################"
echo "# Setup Oracle Packages Required" `date`                                                                                "#"
echo "##########################################################################################################################"

yum install -y bc
yum install -y binutils
yum install -y compat-libcap1
yum install -y compat-libstdc++-33.i686
yum install -y compat-libstdc++-33
yum install -y elfutils-libelf.i686
yum install -y elfutils-libelf
yum install -y elfutils-libelf-devel.i686
yum install -y elfutils-libelf-devel
yum install -y fontconfig-devel
yum install -y glibc.i686
yum install -y glibc
yum install -y glibc-devel.i686
yum install -y glibc-devel
yum install -y ksh
yum install -y libaio.i686
yum install -y libaio
yum install -y libaio-devel.i686
yum install -y libaio-devel
yum install -y libX11.i686
yum install -y libX11
yum install -y libXau.i686
yum install -y libXau
yum install -y libXi.i686
yum install -y libXi
yum install -y libXtst.i686
yum install -y libXtst
yum install -y libXrender-devel.i686
yum install -y libXrender-devel
yum install -y libXrender.i686
yum install -y libXrender
yum install -y libgcc.i686
yum install -y libgcc
yum install -y librdmacm-devel
yum install -y libstdc++.i686
yum install -y libstdc++
yum install -y libstdc++-devel.i686
yum install -y libstdc++-devel
yum install -y libxcb.i686
yum install -y libxcb
yum install -y make
yum install -y nfs-utils
yum install -y net-tools
yum install -y python
yum install -y python-configshell
yum install -y python-rtslib
yum install -y python-six
yum install -y smartmontools
yum install -y sysstat
yum install -y targetcli
yum install -y unixODBC
yum install -y pam

echo "##########################################################################################################################"
echo "# Setup Oracle Groups" `date`                                                                                           "#"
echo "##########################################################################################################################"

/usr/sbin/groupadd -g 54321 ${ORACLE_GROUP}
/usr/sbin/groupadd -g 54322 dba
/usr/sbin/groupadd -g 54323 oper
/usr/sbin/groupadd -g 54324 backupdba
/usr/sbin/groupadd -g 54325 dgdba
/usr/sbin/groupadd -g 54326 kmdba
/usr/sbin/groupadd -g 54330 racdba

echo "##########################################################################################################################"
echo "# Setup Oracle User" `date`                                                                                             "#"
echo "##########################################################################################################################"

/usr/sbin/useradd --uid 54321 --gid ${ORACLE_GROUP} --groups dba,oper,backupdba,dgdba,kmdba,racdba ${ORACLE_USER}
mkdir /home/${ORACLE_USER}/.ssh
cp .ssh/authorized_keys /home/${ORACLE_USER}/.ssh/authorized_keys
chown -R ${ORACLE_USER}:${ORACLE_GROUP} /home/${ORACLE_USER}/.ssh/

echo "##########################################################################################################################"
echo "# Setup Oracle Resource Limits" `date`                                                                                  "#"
echo "##########################################################################################################################"

cat >> /etc/security/limits.conf <<EOF
${ORACLE_USER}  soft    nproc   2047
${ORACLE_USER}  hard    nproc   16384
${ORACLE_USER}  soft    nofile  1024
${ORACLE_USER}  hard    nofile  65536
${ORACLE_USER}  soft    stack   10240
${ORACLE_USER}  hard    stack   32768
${ORACLE_USER}  soft    memlock unlimited
${ORACLE_USER}  hard    memlock unlimited
EOF

echo "##########################################################################################################################"
echo "# Setup Oracle Kernel Parameters" `date`                                                                                "#"
echo "##########################################################################################################################"

cat >> /etc/sysctl.conf <<EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4831838208
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

/sbin/sysctl -p

echo "##########################################################################################################################"
echo "# Setup Oracle Directories and Permissions" `date`                                                                      "#"
echo "##########################################################################################################################"

mkdir -p ${ORACLE_HOME}
mkdir -p ${ORACLE_INVENTORY}
chown -R ${ORACLE_USER}:${ORACLE_GROUP} /u01/ /u02/ /u03/ /u04/ /u05/
chmod -R 775 /u01/ /u02/ /u03/ /u04/ /u05/

echo "##########################################################################################################################"
echo "# Copy Oracle Software." `date`                                                                                         "#"
echo "##########################################################################################################################"

mkdir -p ${SOFTWARE_DIR}
chown ${ORACLE_USER}:${ORACLE_GROUP} ${SOFTWARE_DIR}
cp -f /vagrant/software/${SOFTWARE_FILE} ${SOFTWARE_DIR}
chown ${ORACLE_USER}:${ORACLE_GROUP} ${SOFTWARE_DIR}/${SOFTWARE_FILE}

#su - ${ORACLE_USER} -c 'sh /vagrant/scripts/oracle_user_profile_setup.sh'
cat >> /home/${ORACLE_USER}/.kshrc <<EOF
if [ -t 0 ]; then
stty intr ^C
fi
EOF

cat >> /home/${ORACLE_USER}/.bashrc <<EOF
if [ -t 0 ]; then
stty intr ^C
fi
EOF

cat >> /home/${ORACLE_USER}/.bash_logout <<EOF
if [ -t 0 ]; then
stty intr ^C
fi
EOF

cat >> /home/${ORACLE_USER}/.bash_profile <<EOF
if [ -t 0 ]; then
stty intr ^C
fi

umask 022
export umask
export ORACLE_USER=${ORACLE_USER}
export ORACLE_GROUP=${ORACLE_GROUP}
export ORACLE_BASE=${ORACLE_BASE}
export ORACLE_HOME=${ORACLE_HOME}
export ORACLE_INVENTORY=${ORACLE_INVENTORY}
export ORACLE_SID=${ORACLE_SID}
export ORACLE_HOSTNAME=\`hostname\`
export WALLET_HOME=\$ORACLE_HOME/owm/wallets/${ORACLE_USER}
export LIBPATH=\$ORACLE_HOME/lib:/usr/lib:/lib
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export TNS_ADMIN=\$ORACLE_HOME/network/admin
export EDITOR=vi
export PATH=\$PATH:\$ORACLE_HOME/bin:/usr/sbin
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
export PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin:/usr/sbin:/usr/lbin:/etc:/usr/bin:/usr/ccs/bin/make:/usr/ucb:/usr/bin/X11:/sbin:/bin:/opt/sfw/bin:\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch
PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[32m\]\H:\[\e[0m\]\w]$ '

#the following two parameters are used only at the time the machine is created, they can be removed after the machine is created
export SOFTWARE_DIR=${SOFTWARE_DIR}
export SOFTWARE_FILE=${SOFTWARE_FILE}
EOF

echo "##########################################################################################################################"
echo "# Install software only." `date`                                                                                        "#"
echo "##########################################################################################################################"
su - ${ORACLE_USER} -c 'sh /vagrant/scripts/oracle_software_installation.sh'

echo "##########################################################################################################################"
echo "# Run root scripts." `date`                                                                                             "#"
echo "##########################################################################################################################"
sh ${ORACLE_INVENTORY}/orainstRoot.sh
sh ${ORACLE_HOME}/root.sh

echo "##########################################################################################################################"
echo "# Delete Zip File." `date`                                                                                              "#"
echo "##########################################################################################################################"
rm ${SOFTWARE_DIR}/${SOFTWARE_FILE}

echo "##########################################################################################################################"
echo "# Create Listener." `date`                                                                                              "#"
echo "##########################################################################################################################"
su - ${ORACLE_USER} -c 'sh /vagrant/scripts/create_listener.sh'

echo "##########################################################################################################################"
echo "Create Database." `date`
echo "##########################################################################################################################"
su - oracle -c 'sh /vagrant/scripts/create_database.sh '"${PDB_NAME}"' '"${ALL_PASSWORDS}"''

echo "##########################################################################################################################"
echo "# Automating Shutdown and Startup for the Oracle Instance." `date`                                                      "#"
echo "##########################################################################################################################"
PATTERN=${ORACLE_SID}:${ORACLE_HOME}:N
REPLACEMENT=${ORACLE_SID}:${ORACLE_HOME}:Y
sed -i 's|'"$PATTERN"'|'"$REPLACEMENT"'|' /etc/oratab

cat > /etc/init.d/dbora <<EOF
#! /bin/sh 
# description: Oracle auto start-stop script.
#
# Set ORACLE_HOME to be equivalent to the $ORACLE_HOME
# from which you wish to execute dbstart and dbshut;
#
# Set ORA_OWNER to the user id of the owner of the
# Oracle database in ORACLE_HOME.

ORA_HOME=${ORACLE_HOME}
ORA_OWNER=${ORACLE_USER}

case "\$1" in
'start')
    # Start the Oracle databases:
    # The following command assumes that the oracle login
    # will not prompt the user for any values
    # Remove "&" if you don't want startup as a background process.
    su - \$ORA_OWNER -c "\$ORA_HOME/bin/dbstart \$ORA_HOME" &
    touch /var/lock/subsys/dbora
    ;;

'stop')
    # Stop the Oracle databases:
    # The following command assumes that the oracle login
    # will not prompt the user for any values
    su - \$ORA_OWNER -c "\$ORA_HOME/bin/dbshut \$ORA_HOME" &
    rm -f /var/lock/subsys/dbora
    ;;
esac
EOF

chgrp dba /etc/init.d/dbora
chmod 750 /etc/init.d/dbora

ln -s /etc/init.d/dbora /etc/rc.d/rc0.d/K01dbora
ln -s /etc/init.d/dbora /etc/rc.d/rc3.d/S99dbora
ln -s /etc/init.d/dbora /etc/rc.d/rc5.d/S99dbora
