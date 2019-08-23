<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_timeperiods");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">timeperiod_id</td>
    <td bgcolor="#0000FF">instance_id</td>
    <td bgcolor="#0000FF">config_type</td>
	<td bgcolor="#0000FF">timeperiod_object_id</td>
	<td bgcolor="#0000FF">alias</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['timeperiod_id']; ?></td>
    <td>&nbsp;<?php echo $row['instance_id']; ?></td>
    <td>&nbsp;<?php echo $row['config_type']; ?></td>
	<td>&nbsp;<?php echo $row['timeperiod_object_id']; ?></td>
	<td>&nbsp;<?php echo $row['alias']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>

