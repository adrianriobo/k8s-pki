#!/bin/bash

# PKI path
PKI_EXTERNAL=pki-external
export PKI_DIR=$PKI_EXTERNAL
# PKI required resources: ca.key ca.crt ca.cnf (copy extensions)
PKI_RESOURCES=pki-mock
CSR_FOLDER=target/csr
CRT_FOLDER=target/certs

function create_external_pki {
  mkdir $PKI_EXTERNAL
  mkdir $PKI_EXTERNAL/private $PKI_EXTERNAL/certs $PKI_EXTERNAL/newcerts $PKI_EXTERNAL/crl
  touch $PKI_EXTERNAL/index.txt
  echo '01' > $PKI_EXTERNAL/serial
  cp $PKI_RESOURCES/ca.* $PKI_EXTERNAL/
}

# $1 csr file name
function sign_certificate {
  openssl ca -config $PKI_EXTERNAL/ca.cnf \
  -keyfile $PKI_EXTERNAL/ca.key \
  -cert $PKI_EXTERNAL/ca.crt \
  -out $CRT_FOLDER/$1.crt -infiles $CSR_FOLDER/$1.csr
}

# Main
if [ ! -d $PKI_EXTERNAL ]; then
  create_external_pki
fi

if [ ! -d $CRT_FOLDER ]; then
  mkdir -p $CRT_FOLDER
fi


# Kubelet
# kubelet server TODO read csrs from folder and loop on them
sign_certificate kubelet-server-localhost.localdomain
sign_certificate kubelet-client-localhost.localdomain