<?php
$string = "";
for ($i=0; $i < 800; $i++) { 
$string .= "|||";
$string .= "())(())()()()()";
$string .= "(()()()()()()";
}
header('Content-Length: ' . strlen($string));
var_dump($string);

?>