# make safety copy
cp /etc/pam.d/sshd /etc/pam.d/sshd.original.$(date +"%Y%m%d%H%M")
cp /etc/pam.d/login /etc/pam.d/login.original.$(date +"%Y%m%d%H%M")
# hash pam_tally2 
sed -i 's/^\(auth       required     pam_tally2\.so.*\)/#\1/' /etc/pam.d/sshd
sed -i 's/^\(auth       required     pam_tally2\.so.*\)/#\1/' /etc/pam.d/login
