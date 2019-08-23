<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_notifications");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">notification_id</td>
    <td bgcolor="#0000FF">notification_type</td>
    <td bgcolor="#0000FF">notification_reason</td>
	<td bgcolor="#0000FF">start_time</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['notification_id']; ?></td>
    <td>&nbsp;<?php echo $row['notification_type']; ?></td>
    <td>&nbsp;<?php echo $row['notification_reason']; ?></td>
	<td>&nbsp;<?php echo $row['start_time']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
