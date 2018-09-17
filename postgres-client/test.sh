#!/usr/bin/expect -f
 
set ns $::env(NAMESPACE)
set sv $::env(SERVICE_NAME)
set db $::env(DATABASE_NAME)
set password $::env(PASSWORD)
set user $::env(DATABASE_USER)
set port $::env(PORT)
set parallel $::env(PARALLEL_TRANSACTION)
set transaction $::env(TRANSACTIONS)
#!/usr/bin/expect -f
    
spawn pgbench -i -h $sv.$ns.svc.cluster.local -p $port  -U $user  -s 30 $db
# Look for passwod prompt
expect {

    #timeout {puts "timed out"; exit }
        "connection to database postgres failed:
	could not translate host name pgset.litmus.svc.cluster.local to address: Name or service not known" { exit 1 ; diconnect ; }
		"send: spawn id exp4 not open" { exit ; }
		    "could not translate host name pgset.litmus.svc.cluster.local to address: Name or service not known" { exit 1 ; }
        "Password:"
 
			 } 
			 if {[catch {send "$password\r"} err]} {
				         puts "error sending to $password: $err"
					         exit
						     } else {			     
			send "$password\r"
			send -- "\r"
			expect "#"    }

			set i 1
			while {$i > 0 } {
				#puts "count : $i\n";   #this is for printing th value of variable
				spawn pgbench -c 4 -h $sv.$ns.svc.cluster.local -p $port -U $user  -j $parallel -t $transaction $db
				# Look for passwod prompt
				expect {
				        "connection to database postgres failed:
					could not translate host name pgset.litmus.svc.cluster.local to address: Name or service not known" { exit 1 ; break;}
					    "could not translate host name pgset.litmus.svc.cluster.local to address: Name or service not known" { break ; }
					        "Password:"
					
				} 
				if {[catch {send "$password\r"} err]} {
					puts "error sending to $password: $err"
					exit
				} else {
					# Send password aka $password 
					send "$password\r" ;
					# send blank line (\r) to make sure we get back to gui
					send -- "\r";
					expect "#";
					#set i [expr $i-1];
				}
			}
