<?php
/*
Copyright (c) 2010, akosma software / Adrian Kosmaczewski
All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by akosma software.
4. Neither the name of the akosma software nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

require_once('formatter.php');
require_once(dirname(__FILE__) . '/../libs/protocolbuf/message/pb_message.php');
require_once('pb_proto_person.php');

class ProtocolBufferFormatter extends Formatter
{
    public function formatData()
    {
        // The file "pb_proto_person.php" was created with the following code:
        // require_once(dirname(__FILE__) . '/../libs/protocolbuf/parser/pb_parser.php');
        // $filename = dirname(__FILE__) . '/person.proto';
        // $parser = new PBParser();
        // $parser->parse($filename);
        
        $array = new Data;
        $data = $this->getData();
        while ($entry = $data->next())
        {
            $person = $array->add_person();
            $person->set_entryId(intval($entry['id']));
            $person->set_firstName($entry['first_name']);
            $person->set_lastName($entry['last_name']);
            $person->set_phone($entry['phone']);
            $person->set_email($entry['email']);
            $person->set_address($entry['address']);
            $person->set_city($entry['city']);
            $person->set_zip($entry['zip']);
            $person->set_state($entry['state']);
            $person->set_country($entry['country']);
            $person->set_description($entry['description']);
            $person->set_password($entry['password']);
            $person->set_createdOn($entry['created_on']);
            $person->set_modifiedOn($entry['modified_on']);
        }
        return $array->SerializeToString();
    }
    
    public function getContentType()
    {
        // return "application/octet-stream";
        return "text/plain";
    }
}
?>
