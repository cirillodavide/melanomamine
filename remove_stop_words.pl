#!/usr/bin/perl

# Read the list of stop-words
@stop_words;
#open( FD, "www/stopword1.txt" );
open( FD, "$ARGV[0]" ) 
	|| die( "[remove_stopwords.pl]: The program failed to open stopword list: $ARGV[0].\n" );
while( <FD> ){
	chop;
	push( @stop_words, $_ );
}
close( FD );

#open( FD, "www/additional_stopwords.txt" );
open( FD,  "$ARGV[1]" );
while( <FD> ){
	chop;
	push( @stop_words, $_ );
}
close( FD );

open( WR, ">$ARGV[3]" ) || die( "[remove_stopwords.pl]: The program failed to open file to store filtered feature dictionary: $ARGV[3].\n" );

#open( FD, "word_features" );
open( FD, $ARGV[2] ) || die( "[remove_stopwords.pl]: The program failed to open feature dictionary: $ARGV[2].\n" );
while( <FD> ){
	chop;
	my $flag = 0;
	for( $j=0; $j < @stop_words; $j++ ){
		if( $_ eq $stop_words[$j] ){
			$flag = 1;	
		}
	}

	next if( $flag == 1);
	next if( $_ eq "" );
	print WR $_ . "\n";
}
close( FD );
close( WR );
