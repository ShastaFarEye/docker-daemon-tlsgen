#!/bin/bash



# TODO: https://github.com/docker/docker/issues/7418
# When I use DOCKER_CONFIG tls doesn't seem to work as documented


KEYDIR=/docker-keys
CACERT=${KEYDIR}/dockerkey-ca.pem
CAKEY=${KEYDIR}/dockerkey-cakey.pem

trap ctrl_c INT
ctrl_c() {
  echo "Control+C pressed, exiting"
  exit 255
}

trap term TERM
term() {
  echo "Caught SIGTERM, exiting"
  exit 0
}


gen_ca () {
if [ ! -f "${CACERT}" ] ; then 
   if [ ! -f "${CAKEY}" ] ; then
      echo "no ca key found, making new one"
      generate_cert --cert=${CACERT} --key=${CAKEY}
   else echo "found ${CAKEY} - must not wipe out your key" ; exit 9
   fi
else echo "found ${CACERT} - must not wipe out your cert!" ; exit 99
fi

}
gen_server () {
#get servername
echo "Server Name:"
read SERVER
SERVERKEY=${KEYDIR}/${SERVER}-key.pem
SERVERCERT=${KEYDIR}/${SERVER}-cert.pem
echo "IP address for server:"
read IP

if [ ! -f "${SERVERCERT}" ] ; then
   if [ ! -f "${SERVERKEY}" ] ; then 
      echo "generating server key for ${SERVER} IP: ${IP} "
      generate_cert --host="${SERVER},${IP}" --ca="${CACERT}" --ca-key="${CAKEY}" --cert="${SERVERCERT}" --key="${SERVERKEY}"
   else "found your key for ${SERVER} - remove an retry if you want to remake it" ; exit 3
   fi
else "found your cert for ${SERVER} - remove an retry if you want to remake it" ; exit 2
fi
}
gen_client () {
echo "Client Name:"
read CLIENT
CLIENTKEY=${KEYDIR}/${CLIENT}-key.pem
CLIENTCERT=${KEYDIR}/${CLIENT}-cert.pem

if [ ! -f "${CLIENTCERT}" ] ; then
   if [ ! -f "${CLIENTKEY}" ] ; then 
      echo "generating client key for ${CLIENT} "
      generate_cert --ca="${CACERT}"  --ca-key="${CAKEY}" --cert="${CLIENTCERT}" --key="${CLIENTKEY}"
   else "found your key for ${CLIENT} - remove an retry if you want to remake it" exit 3
   fi
else "found your cert for ${CLIENT} - remove an retry if you want to remake it" ; exit 2
fi
}
#echo "to use the 'boot2docker' tls certificates, set:"
#echo "    export DOCKER_CONFIG=${HOME}/.docker/boot2docker"

if [ ! -f ${CAKEY} ] ; then
   echo "No CA Key found, will try to generate a CA"
   gen_ca
fi
if [ ! -f ${CACERT} ] ; then
   echo "seems like you have a CAKey and no CACert - try again later" ; exit 4
fi
echo "" 
echo "Looks like we have a good CA - let's make a Certificate"
get_type () {
   echo ""
   echo "Server? or Client Cert? [S/C]:"
   read type
   case ${type} in 
      S) gen_server
       ;;
      C) gen_client
       ;;
      *) echo "Please enter S or C" 
       ;;
   esac
}
get_type
