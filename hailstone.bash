#!/bin/bash

WORK=/tmp/hailstone

function min() {
    local i min
    min=shift
    for i in "$@"; do
	if [ $i -lt $min ]; then
	    min=$i
	fi
    done
    echo $min
}

function hailstone() {
    local prev start i
    prev=$1
    start=$2
    i=$3
    if [ $start = 0 -o $i = 0 ]; then
	return
    fi
    echo $start $i >> $WORK
    echo $start "->" $prev
    if [ $((($start - 1) % 3)) = 0 ]; then
	hailstone $start $((($start - 1) / 3)) $(($i-1))
    fi
    hailstone $start $(($start * 2)) $(($i - 1))
}

function main() {
    local limit last
    >$WORK
    limit=${1:-10}
    last=
    echo "digraph G"
    echo "{"
    echo node "[tailport=n,headport=s,shape=box]"
    echo "root=1"
    echo "style=\"invis\""
    for i in $(seq 1 $limit | tac); do
	if [ -n "$last" ]; then
	    echo rank$last "->" rank$i
	fi
	last=$i
    done
    hailstone 1 1 $limit | sort | uniq | sort -n
    <$WORK perl -e '
while (<>) {
  ($word,$val) = /([0-9]+) ([0-9]+)/;
  if (not defined $hash{$word}) {
    $hash{$word} = $val;
  }
  if ($val > $hash{$word}) {
    $hash{$word} = $val;
  } 
}
#print "{ ";
#print "rank" . join "->rank", sort { $b <=> $a } keys %hash;
#print "}\n";
#print "{ rank=same; rank$_; $_ }\n" for keys %hash;
push @{ $inverse{ $hash{$_} } }, $_ for keys %hash;
for $key (keys %inverse) {
  print "{ rank=same; rank$key; " . join(";", @{$inverse{$key}}) . " } // $key\n"
}
'
    echo "}"
}

main "$@"