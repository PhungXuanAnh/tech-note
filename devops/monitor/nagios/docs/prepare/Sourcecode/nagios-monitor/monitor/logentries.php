<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_logentries");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">logentry_id</td>
    <td bgcolor="#0000FF">logentry_time</td>
    <td bgcolor="#0000FF">entry_time</td>
	<td bgcolor="#0000FF">entry_time_usec</td>
	<td bgcolor="#0000FF">logentry_type</td>
	<td bgcolor="#0000FF">logentry_data</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['logentry_id']; ?></td>
    <td>&nbsp;<?php echo $row['logentry_time']; ?></td>
    <td>&nbsp;<?php echo $row['entry_time']; ?></td>
	<td>&nbsp;<?php echo $row['entry_time_usec']; ?></td>
	<td>&nbsp;<?php echo $row['logentry_type']; ?></td>
	<td>&nbsp;<?php echo $row['logentry_data']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
