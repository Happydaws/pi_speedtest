<head>
<title>Den Wilde Speed Tester</title>


<!-- Refresh page automaticly -->
 <meta http-equiv="refresh" content="300">


<!-- CSS Floating image -->
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


<!-- TOP Logo -->
<center><img src="images/logo.png"><br><br>


<!-- Table and head -->
<font color="#FFFFFF">
<table width="99%" border="0"><tr><td width="10%"></td><td align="center">
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
	
### Set timezone ###
	date_default_timezone_set('Europe/Copenhagen');


### Connect to SQLite Database ###
	class MyDB extends SQLite3 {
		function __construct() {
		$this->open('pi_speedtest.sqlite');
		}
	}

	$db = new MyDB();
	if(!$db) {
		echo $db->lastErrorMsg();
	}


### Selecting last 10 records ###
	$sql =<<<EOF
		SELECT * FROM speedtest ORDER BY epoch DESC LIMIT 10;
EOF;
	$ret = $db->query($sql);


### Printing each row in table ###
	while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
		if ($row['status'] == "OK" && isset($row['share'])) { $share = "http://www.speedtest.net/result/" . $row['share'] . ".png"; } else { $share = "images/dot.png"; }
    	echo "<tr>
		<td><font color='#FFFFFF'>". date('d-m-Y', $row['epoch']) . "</font></td>
		<td><font color='#FFFFFF'>". date('H:i', $row['epoch']) . "</font></td>
		<td><font color='#FFFFFF'>". $row['ping'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['download'] . "</font></td>
		<td><font color='#FFFFFF'>". $row['upload'] . "</font></td>
		<td align='center'>
			<div class='imageBox'>
				<div class='imageInn'>
					<img src='images/". $row['status'] . ".png' height='25px' width=25px'></div><div class='hoverImg'><img src='" . $share . "'>
				</div>
			</div>
		</td></tr>";
	}


### Close Database ###
	$db->close();
?>

</table></td><td valign="top" align="right" width="10%">


<!-- Right side table for Webserver info -->
	<table border="1" bordercolor="#FEAAAA" cellspacing="0" cellpadding="10"><tr><td><font color="#FFFFFF">
		<center>Webserver:</center>
	<?php
### Fetching IP's ###
		exec('ip addr show |grep \'inet \' |grep -v \'127.0.0.1\'', $full_output);


### Printing each ip adress and server port ###
		foreach ($full_output as $value) {
			if (preg_match("/(\d+\.\d+\.\d+\.\d+)/", $value, $matches)) {
				print "<br>http://$matches[1]:" . $_SERVER['SERVER_PORT'];
			}
		}
	?>
</font></td></tr></table>
</td></tr></table>
</font></center>