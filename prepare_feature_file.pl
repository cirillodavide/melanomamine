#!/usr/bin/perl

# The script prepares feature file based on the words in positive and negative 
# training collection
%word_count;

# Arguments: 
# 1. positive training examples
# 2. negative training examples
# 3. file for storing the features
open( WR, ">output/removed_words" ) || 
	die( "[prepare_feature_file]: The program is unable to open file to store removed words." );;
&get_features( $ARGV[0] );
&get_features( $ARGV[1] );
close( WR );

# Open the file to store the features
open( WRF, ">$ARGV[2]" ) || 
	die( "[prepare_feature_file]: The program is unable to open file to store the feautures." );
open( WRC, ">output/feature_count" ) || 
	die( "[prepare_feature_file]: The program is unable to open file to store feature count in training data." );;
foreach $key(keys(%word_count) ){
	print WRC $key . " " . $word_count{$key} . "\n";
	print WRF $key . "\n";
}
close( WRF );
close( WRC );

sub get_features{
	my ( $file ) = @_;	
	open( FD, $file ) 
		|| die( "[prepare_feature_file]: The program is unable to open file: $file\n" );
	while( <FD> ){
		chop;
		my( $pmid, $title, $abstract ) = split( /\t/, $_ );
		$abstract =~ s/^\ +//;
		my @words = split( /\ +/, $abstract );
		for( $i = 0; $i < @words; $i++ ){
			$words[$i] =~ s/^\W*//;
			$words[$i] =~ s/\W*$//;
		
			if( $words[$i] =~ /^[0-9]+\W*[0-9]+$/ ){
				print WR $words[$i] . "\n";
				next;
			}
			
			if( $words[$i] =~ /^[0-9]+\W*$/ ){
				print WR $words[$i] . "\n";
				next;
			}

			if( $words[$i] =~ /^[0-9]+.[0-9]+$/ ){
				print WR $words[$i] . "\n";
				next;
			}
			
			if( $words[$i] =~ /^[0-9]+.[0-9]+\W[0-9]+.[0-9]+$/ ){
				print WR $words[$i] . "\n";
				next;
			}

			if( $words[$i] =~ /^\w$/ ){
				print WR $words[$i] . "\n";
				next;
			}
	
			#	print lc($words[$i]) . "\n";
			$word_count{lc($words[$i])}++;
		}	
	}
	close( FD )
}
