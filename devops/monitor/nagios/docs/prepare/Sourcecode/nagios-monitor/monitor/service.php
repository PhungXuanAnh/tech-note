<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_services");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">service_id</td>
    <td bgcolor="#0000FF">config_type </td>
    <td bgcolor="#0000FF">display_name</td>
	<td bgcolor="#0000FF">notify_on_critical</td>
	<td bgcolor="#0000FF">notify_on_recovery</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['service_id']; ?></td>
    <td>&nbsp;<?php echo $row['config_type']; ?></td>
    <td>&nbsp;<?php echo $row['display_name']; ?></td>
	<td>&nbsp;<?php echo $row['notify_on_critical']; ?></td>
	<td>&nbsp;<?php echo $row['notify_on_recovery']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
