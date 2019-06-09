# !/bin/bash  
  

##HTML–Œ Ω  
from='410358630@qq.com'
to='410358630@qq.com'  
  
email_date=''  
email_content='/home/xiaoyuzhou/index.html'  
email_subject='Top800_Game_Free_USA'  
  
  
function send_email(){  
    email_date=$(date "+%Y-%m-%d_%H:%M:%S")  
    echo $email_date  
  
    email_subject=$email_subject"__"$email_date  
    echo $email_subject  
  
    cat $email_content | formail -I "From: $from" -I "MIME-Version:1.0" -I "Content-type:text/html;charset=gb2312" -I "Subject: $email_subject" | /usr/sbin/sendmail -oi $to  
  
}  
  
send_email  