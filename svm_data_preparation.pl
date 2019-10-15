#!/usr/bin/perl

# specify the number of records to be put in test
$no_of_test_instances = $ARGV[0];

open( WRTrain, ">$ARGV[3]" ) || 
	die( "The program can not open the file for writing: $ARGV[3].\n" );

open( WRTest, ">$ARGV[4]" ) ||
	die( "The program can not open the file for writing: $ARGV[4].\n" );

$index = 0;
open( FD, "$ARGV[1]" ) ||
	die( "The program can not open the file for reading : $ARGV[1].\n" );
while( <FD> ){
	if( $index < $no_of_test_instances ){
		print  WRTest $_;			
	}else{
		print  WRTrain $_;			
	}
	$index++;
}
close( FD );

$index = 0;
open( FD, "$ARGV[2]" ) ||
	die( "The program can not open the file for reading : $ARGV[2].\n" );
while( <FD> ){
	if( $index < $no_of_test_instances ){
		print  WRTest $_;			
	}else{
		print  WRTrain $_;			
	}
	$index++;
}
close( FD );

