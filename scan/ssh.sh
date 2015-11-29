username=$1
password=$2
ip=$3

sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip "hostname"