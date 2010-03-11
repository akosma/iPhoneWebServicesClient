#!/usr/bin/env sh

# Copyright (c) 2010, akosma software / Adrian Kosmaczewski
# All rights reserved.
#  
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#    This product includes software developed by akosma software.
# 4. Neither the name of the akosma software nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#  
# THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Add the server name here (without the "http://" prefix)
SERVER="localhost:8888"
LIMIT=$1

if [ "${LIMIT}" = "" ]; then
    LIMIT="20"
fi

echo 
echo "============= Retrieving ${LIMIT} items from the server ============="

echo 
echo "============= HTML ============="
curl http://${SERVER}/index.php\?format=html\&limit=${LIMIT} > data.html

echo 
echo "============= XML Property List ============="
curl http://${SERVER}/index.php\?format=xmlplist\&limit=${LIMIT} > xml.plist

echo 
echo "============= XML Property List (formatted) ============="
curl http://${SERVER}/index.php\?format=xmlplistformatted\&limit=${LIMIT} > xml2.plist

echo 
echo "============= Binary Property List ============="
curl http://${SERVER}/index.php\?format=binplist\&limit=${LIMIT} > bin.plist

echo 
echo "============= JSON ============="
curl http://${SERVER}/index.php\?format=json\&limit=${LIMIT} > data.json

echo 
echo "============= YAML ============="
curl http://${SERVER}/index.php\?format=yaml\&limit=${LIMIT} > data.yaml

echo 
echo "============= SOAP ============="
curl http://${SERVER}/index.php\?format=soap\&limit=${LIMIT} > soap.xml

echo
echo "============= WSDL ============="
curl http://localhost:8888/soap/server.php\?wsdl > wsdl.xml

echo 
echo "============= XML ============="
curl http://${SERVER}/index.php\?format=xml\&limit=${LIMIT} > data.xml

echo 
echo "============= CSV ============="
curl http://${SERVER}/index.php\?format=csv\&limit=${LIMIT} > data.csv

echo 
echo "============= Protocol Buffer ============="
curl http://${SERVER}/index.php\?format=pbuf\&limit=${LIMIT} > data.pbuf
