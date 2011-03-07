#!/usr/bin/expect -f
set timeout 12

#example of getting arguments passed from command line..
#not necessarily the best practice for passwords though...
set server [lindex $argv 0]
set user [lindex $argv 1]
set pass [lindex $argv 2]
set sdir [lindex $argv 3]
set tdir [lindex $argv 4]

# connect to server via ssh, login, and su to root
send_user "connecting to $server\n"
spawn scp -r $sdir $user@$server:$tdir

#login handles cases:
#   login with keys (no user/pass)
#   user/pass
#   login with keys (first time verification)
expect "yes/no" { send "yes\r" }
expect "password:" { send "$pass\r" }

expect {
  default {}
}
