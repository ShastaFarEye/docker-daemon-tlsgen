FROM shastafareye/bash
MAINTAINER Rob Nelson <guruvan@maza.club> "https://maza.club"

COPY . /
VOLUME ["/docker-keys"]
CMD ["/usr/local/bin/make-cert.sh"]
