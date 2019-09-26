<head>
	<title>Den Wilde Speed Tester</title>
	 <meta http-equiv="refresh" content="300">
<style type="text/css">
.imageBox {
  position: relative;
  float: center;
}

.imageBox .hoverImg {
  position: absolute;
  left: 60;
  top: 0;
  display: none;
}

.imageBox:hover .hoverImg {
  display: block;
}
</style>
</head>
<body bgcolor="#000000">
	<center><img src="images/logo.png"><br><br>
	<font color="#FFFFFF">

<table border="1" bordercolor="#FEAAAA" cellspacing="0" cellpadding="10">
	<tr>
		<td><font color="#FFFFFF">DATO</font></td>
		<td><font color="#FFFFFF">TID</font></td>
		<td><font color="#FFFFFF">PING</font></td>
		<td><font color="#FFFFFF">DOWNLOAD</font></td>
		<td><font color="#FFFFFF">UPLOAD</font></td>
		<td><font color="#FFFFFF">STATUS</font></td>
	</tr>

<?php

   class MyDB extends SQLite3 {
      function __construct() {
         $this->open('pi_speedtest.sqlite');
      }
   }
   $db = new MyDB();
   if(!$db) {
      echo $db->lastErrorMsg();
   }


   $sql =<<<EOF
      SELECT * FROM speedtest ORDER BY date, time DESC LIMIT 10;
EOF;

	$ret = $db->query($sql);
	while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {

		if ($row['status'] == "OK" && isset($row['share'])) { $share = "http://www.speedtest.net/result/" . $row['share'] . ".png"; } else { $share = "images/dot.png"; }
    	echo "<tr>
		<td><font color='#FFFFFF'>". $row['date'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['time'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['ping'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['download'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['upload'] . "</font></td>
		<td align='center'><div class='imageBox'><div class='imageInn'><img src='images/". $row['status'] . ".png' height='25px' width=25px'></div><div class='hoverImg'><img src='" . $share . "'>
  </div>
</div></td>
		</tr>";
   }
   $db->close();

?>

</table>
</font></center>