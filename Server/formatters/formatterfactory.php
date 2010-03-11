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

require_once('htmlformatter.php');
require_once('jsonformatter.php');
require_once('yamlformatter.php');
require_once('xmlformatter.php');
require_once('binaryplistformatter.php');
require_once('xmlplistformatter.php');
require_once('soapformatter.php');
require_once('csvformatter.php');
require_once('protocolbufferformatter.php');

class FormatterFactory
{
    static public function createFormatter($type)
    {
        $formatter = null;
        switch($type)
        {
            case "xmlplist":
            {
                $formatter = new XMLPlistFormatter;
                break;
            }
    
            case "xmlplistformatted":
            {
                $formatter = new XMLPlistFormatter(true);
                break;
            }
    
            case "binplist":
            {
                $formatter = new BinaryPlistFormatter;
                break;
            }
        
            case "json":
            {
                $formatter = new JSONFormatter;
                break;
            }
        
            case "soap":
            {
                $formatter = new SOAPFormatter;
                break;
            }

            case "xml":
            {
                $formatter = new XMLFormatter;
                break;
            }
        
            case "yaml":
            {
                $formatter = new YAMLFormatter;
                break;
            }
            
            case "csv":
            {
                $formatter = new CSVFormatter;
                break;
            }
            
            case "pbuf":
            {
                $formatter = new ProtocolBufferFormatter;
                break;
            }

            default:
            {
                $formatter = new HTMLFormatter;
                break;
            }
        }
        return $formatter;
    }
}
?>
