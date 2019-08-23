<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_conninfo");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">conninfo_id</td>
    <td bgcolor="#0000FF">agent_name</td>
    <td bgcolor="#0000FF">agent_version</td>
	<td bgcolor="#0000FF">disposition</td>
	<td bgcolor="#0000FF">connect_source</td>
	<td bgcolor="#0000FF">connect_type</td>
	<td bgcolor="#0000FF">connect_time</td>
	<td bgcolor="#0000FF">disconnect_time</td>
	<td bgcolor="#0000FF">last_checkin_time</td>
	<td bgcolor="#0000FF">data_start_time</td>
	<td bgcolor="#0000FF">data_end_time</td>
	<td bgcolor="#0000FF">bytes_processed</td>
	<td bgcolor="#0000FF">lines_processed</td>
	<td bgcolor="#0000FF">entries_processed</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['conninfo_id']; ?></td>
    <td>&nbsp;<?php echo $row['agent_name']; ?></td>
    <td>&nbsp;<?php echo $row['agent_version']; ?></td>
	<td>&nbsp;<?php echo $row['disposition']; ?></td>
	<td>&nbsp;<?php echo $row['connect_source']; ?></td>
	<td>&nbsp;<?php echo $row['connect_type']; ?></td
	<td>&nbsp;<?php echo $row['connect_time']; ?></td>
	<td>&nbsp;<?php echo $row['disconnect_time']; ?></td>
	<td>&nbsp;<?php echo $row['last_checkin_time']; ?></td>
	<td>&nbsp;<?php echo $row['data_start_time']; ?></td>
	<td>&nbsp;<?php echo $row['data_end_time']; ?></td>
	<td>&nbsp;<?php echo $row['bytes_processed']; ?></td>
	<td>&nbsp;<?php echo $row['lines_processed']; ?></td>
	<td>&nbsp;<?php echo $row['entries_processed']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>

