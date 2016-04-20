#####Build a dumbbell model with N senders and N receivers communicating
#####through two connected routers


set rap 1
set N 3
set bottleNeckLinkDataRate 1024Mb
set lineRate 1024Mb
set RTT1 0.005
set RTT2 0.01
set RTT3 0.005
set packetSize 1460
set routerBufferSize 900 


set simulationTime 50.0
set startMeasurementTime 0.0
set stopMeasurementTime 50.0
set flowClassifyTime 0.04

set congestionControlAlg NewReno
#set congestionControlAlg Cubic

set switchQueueAlg DropTail

set traceSamplingInterval 0.01
set throughputSamplingInterval 0.01
set enableNam 0
set ns [new Simulator]

Agent/TCP set window_ 4000
Agent/TCP set packetSize_ $packetSize

Queue set limit_ 2000


DelayLink set avoidReordering_ true

if {$enableNam != 0} {

	set namfile [open outNewRenoVSUDPParetoS1.nam w]
	$ns namtrace-all $namfile
}

set tf [open outNewRenoVSUDPParetoS1.tr w]
$ns trace-all $tf

set mytracefile [open mytracefileNewRenoVSUDPParetoS1.tr w]
set throughputfile [open thrfileNewRenoVSUDPParetoS1.tr w]

proc finish {} {
	global ns enableNam namfile tf mytracefile throughputfile
	$ns flush-trace
	close $tf
	close $mytracefile
	close $throughputfile
	if {$enableNam != 0} {
		close $namfile
		exec nam outNewRenoVSUDPParetoS1.nam &
	}
	exit 0
}

proc myTrace {file} {
	global ns N traceSamplingInterval tcp qfile MainLink nbow nclient packetSize enable BumponWire

	set now [$ns now]

	for {set i 0} {$i < $N} {incr i} {
		set cwnd($i) [$tcp($i) set cwnd_]
	}

	$qfile instvar parrivals_ pdepartures_ pdrops_ bdepartures_

	puts -nonewline $file "$now $cwnd(0)"
	for {set i 1} {$i < $N} {incr i} {
    puts -nonewline $file " $cwnd($i)"
    }

    puts -nonewline $file " [expr $parrivals_-$pdepartures_-$pdrops_]"    
    puts $file " $pdrops_"
     
    $ns at [expr $now+$traceSamplingInterval] "myTrace $file"
}

$ns color 0 Red
$ns color 1 Orange
$ns color 2 Yellow
$ns color 3 Green
$ns color 4 Blue
$ns color 5 Violet
$ns color 6 Brown
$ns color 7 Black
$ns color 8 Purple
$ns color 9 SeaGreen



set rep 1 
set rng1 [new RNG]
set rng2 [new RNG]
for {set i 0} {$i < $rep} {incr i} {
	$rng1 next-substream;
	$rng2 next-substream;
}

set EXPstart1 [new RandomVariable/Uniform]
$EXPstart1 set min_ 1
$EXPstart1 set max_ 5
$EXPstart1 use-rng $rng1


set EXPstart2 [new RandomVariable/Uniform]
$EXPstart2 set min_ 1
$EXPstart2 set max_ 5
$EXPstart2 use-rng $rng2

for {set i 0} {$i < $N} {incr i} {
	set TCPstartT($i) [expr [$EXPstart1 value]]
}

for {set i 0} {$i < $N} {incr i} {
	set UDPstartT($i) [expr [$EXPstart2 value]]
}

for {set i 0} {$i < $N} {incr i} {
	set s($i) [$ns node]
    set r($i) [$ns node]
}

for {set i 0} {$i < $N} {incr i} {
	set us($i) [$ns node]
    set ur($i) [$ns node]
}
set nqueue1 [$ns node]
set nqueue2 [$ns node]


for {set i 0} {$i < $N} {incr i} {
	$ns duplex-link $s($i) $nqueue1 $lineRate [expr $RTT1] DropTail
	$ns duplex-link $r($i) $nqueue2 $lineRate [expr $RTT3] DropTail
	$ns duplex-link $us($i) $nqueue1 $lineRate [expr $RTT1] DropTail
	$ns duplex-link $ur($i) $nqueue2 $lineRate [expr $RTT3] DropTail
}


$ns simplex-link $nqueue1 $nqueue2 $bottleNeckLinkDataRate [expr $RTT2] DropTail
$ns simplex-link $nqueue2 $nqueue1 $bottleNeckLinkDataRate [expr $RTT2] DropTail
$ns queue-limit $nqueue1 $nqueue2 $routerBufferSize

$ns duplex-link-op $nqueue1 $nqueue2 color "green"
$ns duplex-link-op $nqueue1 $nqueue2 queuePos 0.25
set qfile [$ns monitor-queue $nqueue1 $nqueue2 [open queue.tr w] $traceSamplingInterval]


####Create Error Model
set off [new ErrorModel/Uniform 0 pkt]
set on [new ErrorModel/Uniform 1 pkt] 

set m_states [list $off $on]
# Durations for each of the states, tmp, tmp1 and tmp2, respectively 
#set m_periods [list 0.2 0.1 0.05]
set m_periods [list 4 0.01]
# Transition state model matrix
#set m_transmx { {0 1 0}
#{0 0 1}
#{1 0 0}}
set m_transmx { 
	{0 1}
    {1 0}
}
set m_trunit pkt
# Use time-based transition
set m_sttype time
set m_nstates 2
set m_nstart [lindex $m_states 0]
set em [new ErrorModel/MultiState $m_states $m_periods $m_transmx $m_trunit $m_sttype $m_nstates $m_nstart]


#$ns link-lossmodel $em $nqueue1 $nqueue2

for {set i 0} {$i < $N} {incr i} {
	if {[string compare $congestionControlAlg "NewReno"] == 0} {
		set tcp($i) [new Agent/TCP/Newreno]
		set sink($i) [new Agent/TCPSink/Sack1]
	}
	if {[string compare $congestionControlAlg "Cubic"] == 0} {
		set tcp($i) [new Agent/TCP/Linux]
		$tcp($i) set timestamps_ true
		$ns at 0 "$tcp($i) select_ca cubic"
		set sink($i) [new Agent/TCPSink/Sack1]
	}
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $r($i) $sink($i)

	$tcp($i) set fid_ [expr $i]
	$sink($i) set fid_ [expr $i]

	$ns connect $tcp($i) $sink($i)
}

for {set i 0} {$i < $N} {incr i} {
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	$ns at $TCPstartT($i) "$ftp($i) start"
	$ns at [expr $simulationTime] "$ftp($i) stop"
}
for {set i 0} {$i < $N} {incr i} {
	set udp($i) [new Agent/UDP]
	set null($i) [new Agent/Null]
	$ns attach-agent $us($i) $udp($i)
	$ns attach-agent $ur($i) $null($i)

	$udp($i) set fid_ [expr 5 + $i]

	$ns connect $udp($i) $null($i)
}





# for {set i 0} {$i < [expr $N -2]} {incr i} {
# 	set cbr($i) [new Application/Traffic/CBR]
# 	$cbr($i) attach-agent $udp($i)
# 	$cbr($i) set packetSize_ 1000
# 	$cbr($i) set rate_ 100Mb
# 	$cbr($i) set random_ false
# 	$cbr($i) set interval_ 0.005
# 	$ns at [expr 0.0 + $i] "$cbr($i) start"
# 	$ns at [expr $simulationTime] "$cbr($i) stop"
# }


# set exp1 [new Application/Traffic/Exponential]
# set exp2 [new Application/Traffic/Exponential]
# set exp3 [new Application/Traffic/Exponential]
# $exp1 attach-agent $udp(0)
# $exp2 attach-agent $udp(1)
# $exp3 attach-agent $udp(2)

# $exp1 set packetsize_ 500
# $exp1 set burst_time_ 200ms
# $exp1 set idle_time_ 500ms
# $exp1 set rate_ 100Mb

# $exp2 set packetsize_ 500
# $exp2 set burst_time_ 500ms
# $exp2 set idle_time_ 1s
# $exp2 set rate_ 100Mb

# $exp3 set packetsize_ 500
# $exp3 set burst_time_ 100ms
# $exp3 set idle_time_ 250ms
# $exp3 set rate_ 100Mb

set pareto1 [new Application/Traffic/Pareto]
set pareto2 [new Application/Traffic/Pareto]
set pareto3 [new Application/Traffic/Pareto]
$pareto1 attach-agent $udp(0)
$pareto2 attach-agent $udp(1)
$pareto3 attach-agent $udp(2)

$pareto1 set paketSize_ 500
$pareto1 set burst_time_ 20ms
$pareto1 set idle_time_ 1000ms
$pareto1 set rate_ 100Mb
$pareto1 set shape_ 1.5


$pareto2 set paketSize_ 1460
$pareto2 set burst_time_ 50ms
$pareto2 set idle_time_ 1000ms
$pareto2 set rate_ 1000Mb
$pareto2 set shape_ 1.5

$pareto3 set paketSize_ 1460
$pareto3 set burst_time_ 50ms
$pareto3 set idle_time_ 100ms
$pareto3 set rate_ 500Mb
$pareto3 set shape_ 1.5

$ns at $UDPstartT(0) "$pareto1 start"
$ns at [expr $simulationTime] "$pareto1 stop"

$ns at $UDPstartT(1) "$pareto2 start"
$ns at [expr $simulationTime] "$pareto2 stop"

$ns at $UDPstartT(2) "$pareto3 start"
$ns at [expr $simulationTime] "$pareto3 stop"

# $ns at $UDPstartT(3) "$exp2 start"
# $ns at [expr $simulationTime] "$exp2 stop"

# $ns at $UDPstartT(4) "$exp3 start"
# $ns at [expr $simulationTime] "$exp3 stop"

$ns at $traceSamplingInterval "myTrace $mytracefile"

set flowmon [$ns makeflowmon Fid]
set MainLink [$ns link $nqueue1 $nqueue2]

$ns attach-fmon $MainLink $flowmon

set fcl [$flowmon classifier]

$ns at $flowClassifyTime "classifyFlows"

proc classifyFlows {} {
    global N fcl flowstats
    puts "NOW CLASSIFYING FLOWS"
    for {set i 0} {$i < $N} {incr i} {
    set flowstats($i) [$fcl lookup autp 0 0 $i]
    }
} 


set startPacketCount 0
set stopPacketCount 0

proc startMeasurement {} {
global qfile startPacketCount
$qfile instvar pdepartures_   
set startPacketCount $pdepartures_
}

proc stopMeasurement {} {
global qfile startPacketCount stopPacketCount packetSize startMeasurementTime stopMeasurementTime simulationTime
$qfile instvar pdepartures_   
set stopPacketCount $pdepartures_
puts "Throughput = [expr ($stopPacketCount-$startPacketCount)/(1000000*($stopMeasurementTime-$startMeasurementTime))*$packetSize*8] Mbps"
}


$ns at $startMeasurementTime "startMeasurement"
$ns at $stopMeasurementTime "stopMeasurement"

$ns at $simulationTime "finish"
$ns run
