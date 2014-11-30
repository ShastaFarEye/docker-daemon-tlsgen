docker-daemon-tlsgen - dockerd-tlsgen
=====================================

FROM shastafareye/bash - Baseimage built from 
VOLUME /docker-keys

https://github.com/shastafareye/docker-daemon-tlsgen
https://registry.hub.docker.com/dockerd-tlsgen

mostly "stock" gentoobb / gentoo-base-builder 
Uses Sven's generate_cert.go prebuilt for linux
make-cert.sh script adapted from Sven's original

https://github.com/SvenDowideit/generate_cert

Binaries are built with the included Dockerfiles and 
Makefile:dockerbuild included in the generate_cert project. 


# Usage
<code>
docker run -it --rm -v $(pwd)/my-keys:/docker-keys shastafareye/dockerd-tlsgen
</code>

# Alternatively make it a Dataonly-Volume:
<code>
docker run  --name docker_tlsfiles -v /docker-keys shastafareye/dockerd-tlsgen echo TLSKeyData
</code>
# Use the Datavolume:
<code>
docker run -it --rm --volumes-from docker_tlsfiles shastafareye/dockerd-tlsgen
</code>
# Backup keys from Volume:
<code>
docker run -it --rm \
  --name tlsfiles_backup \
  --volumes-from docker_tlsfiles \
  -v $(pwd):/backup \
  shastafareye/dockerd-tlsgen \
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
docker build -t REPO/dockerd-tlsgen
</code>

## Security of certificates and proper usages with Docker Client & Daemon is an exercise for the reader!
