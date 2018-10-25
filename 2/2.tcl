set ns [new Simulator]
set f [open 2.tr w]
$ns trace-all $f
set nf [open 2.nam w]
$ns namtrace-all $nf

$ns color 1 Blue
$ns color 2 Red

proc finish {} {
	global ns f nf
	$ns flush-trace
	close $f
	close $nf
	exec nam 2.nam &
	puts "The number of ping packets dropped are" 
	exec grep "^d" 2.tr | cut -d " " -f 5 | grep -c "ping" &
	exit 0
}


set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.5Mb 30ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n3 $n5 1Mb 10ms DropTail

set ping0 [new Agent/Ping]
$ping0 set class_ 1
$ns attach-agent $n0 $ping0

set ping4 [new Agent/Ping]
$ping4 set class_ 2
$ns attach-agent $n4 $ping4
$ns connect $ping0 $ping4

proc sendPingPacket {} {
	global ns ping0 ping4
	set intervalTime 0.001
	set now [$ns now]
	$ns at [expr $now + $intervalTime] "$ping0 send"
	$ns at [expr $now + $intervalTime] "$ping4 send"
	$ns at [expr $now + $intervalTime] "sendPingPacket"  
}

Agent/Ping instproc recv {from rtt} {
	$self instvar node_
	puts "The node [$node_ id] received and ping ACK from the node from $from with Round-Trip-Time $rtt ms"
}

$ns at 0.01 "sendPingPacket"
$ns at 10.0 "finish"
$ns run
