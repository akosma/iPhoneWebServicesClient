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

class XMLFormatter extends Formatter
{
    public function formatData()
    {
        $array = Formatter::generateArrayFromData($this->getData());
        return $this->arrayToXML($array);
    }

    public function getContentType()
    {
        return "text/xml";
    }

    // Adapted from 
    // http://snipplr.com/view/3491/convert-php-array-to-xml-or-simple-xml-object-if-you-wish/
    private function arrayToXML($data, $rootNodeName = 'data', $xml = null)
    {
    	// turn off compatibility mode as simple xml throws a wobbly if you don't.
    	if (ini_get('zend.ze1_compatibility_mode') == 1)
    	{
    		ini_set ('zend.ze1_compatibility_mode', 0);
    	}
	
    	if ($xml == null)
    	{
    		$xml = simplexml_load_string("<?xml version='1.0' encoding='utf-8'?><$rootNodeName />");
    	}
	
    	// loop through the data passed in.
    	foreach($data as $key => $value)
    	{
    		// no numeric keys in our xml please!
    		if (is_numeric($key))
    		{
    			// make string key...
    			$key = "person_". (string) $key;
    		}
		
    		// replace anything not alpha numeric
    		$key = preg_replace('/[^a-z]/i', '', $key);
		
    		// if there is another array found recrusively call this function
    		if (is_array($value))
    		{
    			$node = $xml->addChild($key);
    			// recursive call.
    			$this->arrayToXML($value, $rootNodeName, $node);
    		}
    		else 
    		{
    			// add single node.
                                $value = htmlentities($value);
    			$xml->addChild($key,$value);
    		}
		
    	}
    	// pass back as string. or simple xml object if you want!
    	return $xml->asXML();
    }
}
?>
