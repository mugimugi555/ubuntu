<?php

exec( "/root/usbrh-linux/usbrh" , $result );
$tmp = explode( " ", $result[0] );
$RESULT_TMP = $tmp[0];
$RESULT_HUM = $tmp[1];
$COMFORT = intval( 0.81 * $RESULT_TMP + 0.01 * $RESULT_HUM * ( 0.99 * $RESULT_TMP - 14.3 ) + 46.3 );

$now = date('Y-m-d H:i:s');

$JSON = <<<JSON
{
  "datetime":"{$now}",
  "temperature":{$RESULT_TMP},
  "humidity":{$RESULT_HUM},
  "comfort":{$COMFORT}
}
JSON;

file_put_contents( "/var/www/html/usbrh.json" , $JSON );
echo $JSON;

exit;
