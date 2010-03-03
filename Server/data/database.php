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
class Connection
{        
    var $server;
    var $user;
    var $password;
    var $database;
    var $connection;

    function Connection()
    {
        $this->server = 'localhost';
        $this->user = 'root';
        $this->password = 'root';
        $this->database = 'data';
    }

    function open()
    {
        $this->connection = mysql_pconnect($this->server, $this->user, $this->password) 
            or trigger_error(mysql_error(), E_USER_ERROR);
    }
    
    function execute($consulta)
    {
        mysql_select_db($this->database, $this->connection);
        $results = mysql_query($consulta, $this->connection) or die(mysql_error());
        $recordset = new Recordset($results);
        return $recordset;
    }
    
    function close()
    {
        $this->connection = null;
    }
}

class Recordset
{
    var $recordset;
    var $count;
    
    function Recordset($rs)
    {
        $this->recordset = $rs;
        $this->count = mysql_num_rows($rs);
    }
    
    function next()
    {
        return mysql_fetch_assoc($this->recordset);
    }
    
    function count()
    {
        return $this->count;
    }
    
    function close()
    {
        mysql_free_result($this->recordset);
        $this->recordset = null;
    }
}

function execute($query)
{
    $conn = new Connection;
    $conn->open();
    $recordset = $conn->execute($query);
    $conn->close();
    return $recordset;
}
?>
