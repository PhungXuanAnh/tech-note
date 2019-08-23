<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_servicechecks");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">servicecheck_id</td>
    <td bgcolor="#0000FF">check_type</td>
    <td bgcolor="#0000FF">current_check_attempt</td>
	<td bgcolor="#0000FF">max_check_attempts</td>
	<td bgcolor="#0000FF">state</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['servicecheck_id']; ?></td>
    <td>&nbsp;<?php echo $row['check_type']; ?></td>
    <td>&nbsp;<?php echo $row['current_check_attempt']; ?></td>
	<td>&nbsp;<?php echo $row['max_check_attempts']; ?></td>
	<td>&nbsp;<?php echo $row['state']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>
