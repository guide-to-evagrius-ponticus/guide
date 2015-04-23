<?php

$YourEmailAddress = 'kalvesmaki@gmail.com'; //Email address you want the mail to go to
$Yourname = 'Joel Kalvesmaki'; //Who the email is sent from - this is a name not an email
$MailUsername ='joel@kalvesmaki.com'; //Email address you are using to send the email
$MailPassword = 'bo45Woo'; //This is the password of the email account used to send the email
$MailServer = 'smtp.kalvesmaki.com'; //Assigned mail server
$MailType = 'TEXT'; // Can use HTML or TEXT -case doesn't matter
$full_name = $_POST['full_name'];
$email = $_POST['email'];
$comments = $_POST['comments'];
$checksum = $_POST['csum'];
$previous = $_SERVER['HTTP_REFERER']; // Find out where the person came from
$empty = $post = array();

function contains_bad_str($str_to_test) {
  $bad_strings = array(
        "content-type:"
        ,"mime-version:"
        ,"multipart/mixed"
		,"Content-Transfer-Encoding:"
        ,"bcc:"
		,"cc:"
		,"to:"
  );
  
  foreach($bad_strings as $bad_string) {
    if(eregi($bad_string, strtolower($str_to_test))) {
      echo "$bad_string found. Suspected injection attempt - mail not being sent.";
      exit;
    }
  }
}

function contains_newlines($str_to_test) {
   if(preg_match("/(%0A|%0D|\\n+|\\r+)/i", $str_to_test) != 0) {
     echo "newline found in $str_to_test. Suspected injection attempt - mail not being sent.";
     exit;
   }
} 

echo "<p>Return to <a href='".$previous."'>previous page</a>.</p>";

require("phpmailer/class.phpmailer.php"); 

if(strtolower($MailType) == 'html'){
$mailtypetosend = true;
} else {
$mailtypetosend = false;
}

$mail = new PHPMailer();

$mail->From = $MailUsername;
$mail->FromName = $full_name;
$mail->Host = $MailServer;
$mail->Mailer = "smtp";

$mail->SMTPAuth = true; // turn on SMTP authentication
$mail->Username = $MailUsername; // SMTP username
$mail->Password = $MailPassword; // SMTP password

$mail->AddAddress($YourEmailAddress, $Yourname);
$mail->AddReplyTo($email, $full_name);

$mail->WordWrap = 50; // set word wrap to 50 characters
$mail->IsHTML($mailtypetosend); // True for HTML, FALSE for plain text
$mail->SetLanguage("en", "language/");

//Protections against bad data and spamming
if($_SERVER['REQUEST_METHOD'] != "POST"){
   echo("Unauthorized attempt to access page.");
   exit;
}
if (empty($_POST['full_name'])) {
$full_name = FALSE;
$message .= '<br>Please enter your name</br>';
} else {
$full_name = $_POST['full_name'];
}
if (empty($_POST['email']) or !preg_match('/^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/',$email)) {
$email = FALSE;
$message .= '<br>Please enter a valid email address</br>';
} else {
$email = $_POST['email'];
}
if (empty($_POST['comments']) or !preg_match('/^11$/',$checksum)) {
$comments = FALSE;
$message .= '<br>You did not enter a message or you did not answer the question correctly</br>';
} else {
$comments = $_POST['comments'];
}
contains_bad_str($email);
contains_bad_str($comments);

contains_newlines($email);
contains_newlines($comments);

if($comments && $email && $full_name && $checksum){

$mail->Subject = "general inquiry";
$mail->Body .= "Referred from $previous \n";
$mail->Body .= "Name: $full_name \n";
$mail->Body .= "Email Address: $email\n";
$mail->Body .= "Message: $comments\n\n\n";

if(!$mail->Send())
{
echo "Message could not be sent. <p>";
echo "Mailer Error: " . $mail->ErrorInfo;
exit;
} else {
$sent = 1;
}

echo "<p>If your message requires a response, I will be in touch with you at ".$email." in due course.</p>";
}
if(isset($message)) {echo "<left><u><b>$message</span></b></u></left><br>";}

?>