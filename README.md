docker-daemon-tlsgen
=====================================

FROM shastafareye/bash - 
Baseimage built with gentoobb base builder kit
from https://github.com/edannenberg/gentoo-bb

VOLUME /docker-keys
ENTRYPOINT /usr/local/bin/make-cert.sh

Source available on github:
https://github.com/shastafareye/docker-daemon-tlsgen
Automated Build on Dockerhub from Github Sources:
https://registry.hub.docker.com/u/shastafareye/docker-daemon-tlsgen/

mostly "stock" gentoobb / gentoo-base-builder 
Uses Sven's generate_cert.go prebuilt for linux
make-cert.sh script adapted from Sven's original

https://github.com/SvenDowideit/generate_cert

Binaries are built with the included Dockerfiles and 
Makefile:dockerbuild included in the generate_cert project. 


# Usage
<code>
docker run -it --rm -v $(pwd)/my-keys:/docker-keys shastafareye/docker-daemon-tlsgen
</code>
This will 
 - mount your current directory into /docker-keys
 - look for a CA certificate and key
 - make a new CA if needed
 - use your existing CA if present in correct form
 - stop if you're missing either CA cert or CA Key
 - And then it will ask you if you'd like a Client or Server Cert and make one for you

Server certs require a servername and IP address
Client certs require a name
Script will bail if your chosen name exists. 

Error checking is not exhaustive, make backups ;) 

# Use as a Dataonly-Volume:
<code>
docker run  --name docker_tlsfiles -v /docker-keys shastafareye/docker-daemon-tlsgen echo TLSKeyData
</code>
# Use the Datavolume:
<code>
docker run -it --rm --volumes-from docker_tlsfiles shastafareye/docker-daemon-tlsgen
</code>
# Backup keys from Volume:
<code>
docker run -it --rm \
  --name tlsfiles_backup \
  --volumes-from docker_tlsfiles \
  -v $(pwd):/backup \
  shastafareye/docker-daemon-tlsgen \
  tar -cpvf /backup/docker-keys.tar /docker-keys 
</code>


# Build Yourself (from source)
<code> 
git clone https://github.com/SvenDowideit/generate_cert
cd generate_cert
make dockerbuild
cp generate_cert-0.1-linux-amd64 generate_cert
git clone https://github.com/shastafareye/docker-daemon-tlsgen
rm docker-daemon-tlsgen/usr/local/bin/generate_cert
cp -av generate_cert-0.1-linux-amd64 docker-daemon-tlsgen/usr/local/bin/generate_cert
cd docker-daemon-tlsgen
docker build -t REPO/docker-daemon-tlsgen
</code>

## Security of certificates and proper usages with Docker Client & Daemon is an exercise for the reader!
