<?php
if ($_SERVER['HTTP_X_GITHUB_EVENT'] == 'push') {
  shell_exec( 'cd /home/admin/web/garethmcfarlane.net/public_html/ && git pull' );
}
?>
