<?php
	mysql_connect("localhost","ndoutils","anhdat96");
	mysql_select_db("nagios");
	$tb = mysql_query("select * from nagios_hosts");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">host_id</td>
    <td bgcolor="#0000FF">instance_id</td>
    <td bgcolor="#0000FF">address</td>
  </tr>
  <?php
  	while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['host_id']; ?></td>
    <td>&nbsp;<?php echo $row['instance_id']; ?></td>
    <td>&nbsp;<?php echo $row['address']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
