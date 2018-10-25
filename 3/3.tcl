set ns [new Simulator]
set f [open 3.tr w]
$ns trace-all $f

set nf [open 3.nam w]
$ns namtrace-all $nf

$ns color 1 Blue
$ns color 2 Red

proc finish {} {
	global ns f nf outFile1 outFile2
	$ns flush-trace
	close $f
	close $nf
	exec nam 3.nam &
	exec xgraph Congestion1.xg -geometry 400x400 &
	exec xgraph Congestion2.xg -geometry 400x400 &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.6Mb 10ms DropTail

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns make-lan "$n3 $n4 $n5" 10Mb 30ms LL Queue/DropTail Mac/802_3

set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
$tcp1 set fid_ 1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1
$ftp1 set maxPkts_ 1000
$ns connect $tcp1 $sink1

set tcp2 [new Agent/TCP]
$ns attach-agent $n1 $tcp2
$tcp2 set fid_ 1
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n5 $sink2
$ftp2 set maxPkts_ 1000
$ns connect $tcp2 $sink2

set outFile1 [open Congestion1.xg w]
set outFile2 [open Congestion2.xg w]

proc findWindowSize {tcpSource outFile} {
	global ns
	set now [$ns now]
	set cWindSize [$tcpSource set cwnd_]
	puts $outFile "$now $cWindSize"
	$ns at [expr $now + 0.1] "findWindowSize $tcpSource $outFile"
}

$ns at 0.0 "findWindowSize $tcp1 $outFile1"
$ns at 0.1 "findWindowSize $tcp2 $outFile2"
$ns at 0.3 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 50.0 "$ftp1 stop"
$ns at 50.0 "$ftp2 stop"
$ns at 50.0 "finish"
$ns run
