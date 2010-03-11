<?php
class Person extends PBMessage
{
  var $wired_type = PBMessage::WIRED_LENGTH_DELIMITED;
  public function __construct($reader=null)
  {
    parent::__construct($reader);
    $this->fields["1"] = "PBInt";
    $this->values["1"] = "";
    $this->fields["2"] = "PBString";
    $this->values["2"] = "";
    $this->fields["3"] = "PBString";
    $this->values["3"] = "";
    $this->fields["4"] = "PBString";
    $this->values["4"] = "";
    $this->fields["5"] = "PBString";
    $this->values["5"] = "";
    $this->fields["6"] = "PBString";
    $this->values["6"] = "";
    $this->fields["7"] = "PBString";
    $this->values["7"] = "";
    $this->fields["8"] = "PBString";
    $this->values["8"] = "";
    $this->fields["9"] = "PBString";
    $this->values["9"] = "";
    $this->fields["10"] = "PBString";
    $this->values["10"] = "";
    $this->fields["11"] = "PBString";
    $this->values["11"] = "";
    $this->fields["12"] = "PBString";
    $this->values["12"] = "";
    $this->fields["13"] = "PBString";
    $this->values["13"] = "";
    $this->fields["14"] = "PBString";
    $this->values["14"] = "";
  }
  function entryId()
  {
    return $this->_get_value("1");
  }
  function set_entryId($value)
  {
    return $this->_set_value("1", $value);
  }
  function firstName()
  {
    return $this->_get_value("2");
  }
  function set_firstName($value)
  {
    return $this->_set_value("2", $value);
  }
  function lastName()
  {
    return $this->_get_value("3");
  }
  function set_lastName($value)
  {
    return $this->_set_value("3", $value);
  }
  function phone()
  {
    return $this->_get_value("4");
  }
  function set_phone($value)
  {
    return $this->_set_value("4", $value);
  }
  function email()
  {
    return $this->_get_value("5");
  }
  function set_email($value)
  {
    return $this->_set_value("5", $value);
  }
  function address()
  {
    return $this->_get_value("6");
  }
  function set_address($value)
  {
    return $this->_set_value("6", $value);
  }
  function city()
  {
    return $this->_get_value("7");
  }
  function set_city($value)
  {
    return $this->_set_value("7", $value);
  }
  function zip()
  {
    return $this->_get_value("8");
  }
  function set_zip($value)
  {
    return $this->_set_value("8", $value);
  }
  function state()
  {
    return $this->_get_value("9");
  }
  function set_state($value)
  {
    return $this->_set_value("9", $value);
  }
  function country()
  {
    return $this->_get_value("10");
  }
  function set_country($value)
  {
    return $this->_set_value("10", $value);
  }
  function description()
  {
    return $this->_get_value("11");
  }
  function set_description($value)
  {
    return $this->_set_value("11", $value);
  }
  function password()
  {
    return $this->_get_value("12");
  }
  function set_password($value)
  {
    return $this->_set_value("12", $value);
  }
  function createdOn()
  {
    return $this->_get_value("13");
  }
  function set_createdOn($value)
  {
    return $this->_set_value("13", $value);
  }
  function modifiedOn()
  {
    return $this->_get_value("14");
  }
  function set_modifiedOn($value)
  {
    return $this->_set_value("14", $value);
  }
}
class Data extends PBMessage
{
  var $wired_type = PBMessage::WIRED_LENGTH_DELIMITED;
  public function __construct($reader=null)
  {
    parent::__construct($reader);
    $this->fields["1"] = "Person";
    $this->values["1"] = array();
  }
  function person($offset)
  {
    return $this->_get_arr_value("1", $offset);
  }
  function add_person()
  {
    return $this->_add_arr_value("1");
  }
  function set_person($index, $value)
  {
    $this->_set_arr_value("1", $index, $value);
  }
  function remove_last_person()
  {
    $this->_remove_last_arr_value("1");
  }
  function person_size()
  {
    return $this->_get_arr_size("1");
  }
}
?>