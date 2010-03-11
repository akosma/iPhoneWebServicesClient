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

class SOAPFormatter extends Formatter
{
    public function formatData()
    {
        $path = $this->currentServer() . "soap/server.php";
        $request_file = dirname(__FILE__) . "/soaprequest.xml";
        $file_contents = file_get_contents($request_file);
        $limit = $this->getData()->count();
        $xml_request = str_replace("{REQUEST_LIMIT}", $limit, $file_contents);

        $headers = array(
            "Content-Type: text/xml; charset=utf-8"
        );

        $conn = curl_init();
        curl_setopt($conn, CURLOPT_URL, $path);
        curl_setopt($conn, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($conn, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($conn, CURLOPT_POSTFIELDS, $xml_request);
        curl_setopt($conn, CURLOPT_RETURNTRANSFER, 1);
        $data = curl_exec($conn);
        curl_close($conn);
        return $data;
    }

    public function getContentType()
    {
        return "text/xml";
    }
    
    // Adapted from
    // http://www.webcheatsheet.com/PHP/get_current_page_url.php
    public function currentServer() 
    {
        $pageURL = 'http';
        if ($_SERVER["HTTPS"] == "on") 
        {
            $pageURL .= "s";
        }
        $pageURL .= "://";
        if ($_SERVER["SERVER_PORT"] != "80") 
        {
            $pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"];
        } 
        else 
        {
            $pageURL .= $_SERVER["SERVER_NAME"];
        }
        $pageURL .= str_replace("index.php", "", $_SERVER["PHP_SELF"]);
        return $pageURL;
    }
}
?>
