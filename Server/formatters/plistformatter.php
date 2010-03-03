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
require_once(dirname(__FILE__) . '/../libs/cfpropertylist/CFPropertyList.php');

abstract class PListFormatter extends Formatter
{
    protected function generatePlistFromData()
    {
        $plist = new CFPropertyList();
        $plist->add($array = new CFArray());
        while ($entry = $this->getData()->next())
        {
            $array->add($this->formatEntryAsPlist($entry));
        }
        return $plist;
    }

    private function formatEntryAsPlist($entry)
    {
        $dict = new CFDictionary();
        $dict->add('entryId', new CFNumber($entry['id']));
        $dict->add('firstName', new CFString($entry['first_name']));
        $dict->add('lastName', new CFString($entry['last_name']));
        $dict->add('phone', new CFString($entry['phone']));
        $dict->add('email', new CFString($entry['email']));
        $dict->add('address', new CFString($entry['address']));
        $dict->add('city', new CFString($entry['city']));
        $dict->add('zip', new CFString($entry['zip']));
        $dict->add('state', new CFString($entry['state']));
        $dict->add('country', new CFString($entry['country']));
        $dict->add('description', new CFString($entry['description']));
        $dict->add('password', new CFString($entry['password']));
        $dict->add('createdOn', new CFString($entry['created_on']));
        $dict->add('modifiedOn', new CFString($entry['modified_on']));
        return $dict;
    }
}
?>
