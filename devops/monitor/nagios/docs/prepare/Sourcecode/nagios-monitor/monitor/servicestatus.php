<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_servicestatus");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">servicestatus_id</td>
    <td bgcolor="#0000FF">status_update_time</td>
    <td bgcolor="#0000FF">output</td>
	<td bgcolor="#0000FF">long_output</td>
	<td bgcolor="#0000FF">current_state</td>
	<td bgcolor="#0000FF">last_time_ok</td>
	<td bgcolor="#0000FF">last_time_warning</td>
	<td bgcolor="#0000FF">retry_check_interval</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['servicestatus_id']; ?></td>
    <td>&nbsp;<?php echo $row['status_update_time']; ?></td>
    <td>&nbsp;<?php echo $row['output']; ?></td>
	<td>&nbsp;<?php echo $row['long_output']; ?></td>
	<td>&nbsp;<?php echo $row['current_state']; ?></td>
	<td>&nbsp;<?php echo $row['last_time_ok']; ?></td>
	<td>&nbsp;<?php echo $row['last_time_warning']; ?></td>
	<td>&nbsp;<?php echo $row['retry_check_interval']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
