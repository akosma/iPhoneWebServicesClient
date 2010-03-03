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

class HTMLFormatter extends Formatter
{
    public function getContentType()
    {
        return "text/html";
    }

    public function formatData()
    {
        ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<title>data</title>
</head>

<body>

<table border="1" cellpadding="3" cellspacing="0">
    <tr>
        <th>id</th>
        <th>first name</th>
        <th>last name</th>
        <th>phone</th>
        <th>email</th>
        <th>address</th>
        <th>city</th>
        <th>zip</th>
        <th>state</th>
        <th>country</th>
        <th>description</th>
        <th>password</th>
        <th>created on</th>
        <th>modified on</th>
    </tr>
<?php
while ($entry = $this->getData()->next())
{
    $this->formatEntryAsHTML($entry);
}
?>    
</table>

</body>
</html>
        <?php
    }

    private function formatEntryAsHTML($entry)
    {
        echo("<tr>");
        echo("<td>" . $entry['id'] . "</td>");
        echo("<td>" . $entry['first_name'] . "</td>");
        echo("<td>" . $entry['last_name'] . "</td>");
        echo("<td>" . $entry['phone'] . "</td>");
        echo("<td>" . $entry['email'] . "</td>");
        echo("<td>" . $entry['address'] . "</td>");
        echo("<td>" . $entry['city'] . "</td>");
        echo("<td>" . $entry['zip'] . "</td>");
        echo("<td>" . $entry['state'] . "</td>");
        echo("<td>" . $entry['country'] . "</td>");
        echo("<td>" . $entry['description'] . "</td>");
        echo("<td>" . $entry['password'] . "</td>");
        echo("<td>" . $entry['created_on'] . "</td>");
        echo("<td>" . $entry['modified_on'] . "</td>");
        echo("</tr>");
    }
}
?>
