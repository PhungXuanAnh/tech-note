<?php
        mysql_connect("localhost","ndoutils","anhdat96");
        mysql_select_db("nagios");
        $tb = mysql_query("select * from nagios_objects");
?>
<table width="494" height="69" border="1" bgcolor="#99FFFF">
  <tr>
    <td bgcolor="#0000FF">object_id</td>
    <td bgcolor="#0000FF">instance_id</td>
    <td bgcolor="#0000FF">objecttype_id</td>
	<td bgcolor="#0000FF">name1</td>
	<td bgcolor="#0000FF">name2</td>
	<td bgcolor="#0000FF">is_active</td>
  </tr>
  <?php
        while($row=mysql_fetch_array($tb)){
  ?>
  <tr>
    <td>&nbsp;<?php echo $row['object_id']; ?></td>
    <td>&nbsp;<?php echo $row['instance_id']; ?></td>
    <td>&nbsp;<?php echo $row['objecttype_id']; ?></td>
	<td>&nbsp;<?php echo $row['name1']; ?></td>
	<td>&nbsp;<?php echo $row['name2']; ?></td>
	<td>&nbsp;<?php echo $row['is_active']; ?></td>
  </tr>
  <?php
  }
  ?>
</table>

