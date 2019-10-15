#!/usr/bin/perl

# the perl script analyzes the model
# read feature description
@feat_label = 0;
open( FD, $ARGV[0] );
while( <FD> ){
	chop;
	push( @feat_label, $_ );
}
close( FD );

# read the model
@mlines;
open( MD, $ARGV[1] );
while( <MD> ){
	chop;
	push( @mlines, $_ );	
}
close( MD );

my($b_threshold, $comment) = split( /\#/, $mlines[10] );
print "b= ". $b_threshold . "\n";

%w = null ;
for($i=11 ; $i<@mlines ; $i++) {
  chop($mlines[$i]) ;

  my($mscore, $sequence ) = split( /#/, $mlines[$i] );

  $mlines[$i] = $mscore ;
  @wwords = split(' ', $mlines[$i]) ;
  $alphay[$i-11] = $wwords[0] ;

  for($j=1 ; $j<@wwords ; $j++) {
    ($wfeat, $wval) = split(':', $wwords[$j]) ;
    $w{$wfeat} += ($alphay[$i-11] * $wval) ;
  }
}

# check if \sum{alphay} = 0
$aysum = 0.0 ;
for($i=0 ; $i<@alphay ; $i++) {
  $aysum += $alphay[$i] ;
}
printf("Sum(alpha*y) = %.10f\n", $alsum) ;

print "Printing scores \n";
foreach $key (sort {$a<=>$b} keys (%w)) {
	print $key . " " . $feat_label[$key] . " " . $w{$key} . "\n";	
}
