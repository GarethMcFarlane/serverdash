<?php
if ( $_POST['payload'] ) {
  shell_exec( 'cd /home/admin/web/garethmcfarlane.net/public_html/ && git pull' );
}
?>
