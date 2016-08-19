<?php
// We want to track our users
session_start();
?>
<!DOCTYPE html>
<html><body>
<?php
// you need a database to store things
$db_host = getenv('DB_HOST');
$db_user = getenv('DB_USER');
$db_pass = getenv('DB_PASS');
$dbh = new mysqli($db_host, $db_user, $db_pass);

// ensure it's working
$res = $dbh->query("SELECT 'db connected' AS _msg FROM DUAL");
$row = $res->fetch_assoc();

printf("<!-- %s -->\n", $row['_msg']);

// Allow user to change their name, this is important for user experience
// https://www.youtube.com/watch?v=nW-bFGzNMXw&t=31
if (isset($_POST['Submit'])) { $_SESSION['user'] = $_POST['user']; }
if (!isset($_SESSION['user'])) { $_SESSION['user'] = session_id(); }
session_write_close();
$user=$_SESSION['user'];

// Ensure structure is correct
$dbh->query("CREATE DATABASE IF NOT EXISTS apps");
$dbh->select_db('apps');
$dbh->query("CREATE TABLE IF NOT EXISTS app1(id VARCHAR(255), points INT, PRIMARY KEY (id))");

// Give the user things so they want to come back
// https://www.youtube.com/watch?v=qi4jKa6jaek
$dbh->query("INSERT INTO app1(id, points) VALUES ('$user', 1) ON DUPLICATE KEY UPDATE points = points + 1");

$res = $dbh->query("SELECT points FROM app1 WHERE id='$user'");
$row = $res->fetch_assoc();
printf("Hey %s, your score is %d", $user, $row['points']);
?>
<br />

<form action="" method="post">
Username: <input type="text" name="user" value="<?php echo $user; ?>"/>
<input type="submit" name="Submit" value="Change!" />
</form>

</body></html>
