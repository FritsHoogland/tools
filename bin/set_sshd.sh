# make safety copy
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original.$(date +"%Y%m%d%H%M")
# remove hash if it's there
sed -i 's/^#ClientAliveCountMax/ClientAliveCountMax/' /etc/ssh/sshd_config
sed -i 's/^#ClientAliveInterval/ClientAliveInterval/' /etc/ssh/sshd_config
# set sensible values
sed -i 's/^ClientAliveCountMax\ [0-9]*/ClientAliveCountMax 60/' /etc/ssh/sshd_config
sed -i 's/^ClientAliveInterval\ [0-9]*/ClientAliveInterval 60/' /etc/ssh/sshd_config
# let sshd reload new config
/etc/rc.d/init.d/sshd reload
