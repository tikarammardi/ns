set ns [new Simulator]
set f [open 1.tr w]
$ns trace-all $f

set nf [open 1.nam w]
$ns namtrace-all $nf

proc finish {} {
	global f nf ns
	$ns flush-trace
	close $f
	close $nf
	exec nam 1.nam &
	exec echo "The number of packet drops is" &
	exec grep -c "^d" 1.tr &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n0 $n1 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.3Mb 20ms DropTail
$ns queue-limit $n1 $n2 10

set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005

set null [new Agent/Null]
$ns attach-agent $n2 $null

$ns connect $udp $null

$ns at 0.1 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
$ns run
