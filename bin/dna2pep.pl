#!/usr/bin/perl
 
use strict;
use LWP::UserAgent;
use warnings;
  
my $browser  = LWP::UserAgent->new;
my $dna_sequence = 'ATCG....AGCTAG';
my $response = $browser->post(
	'https://web.expasy.org/cgi-bin/translate/dna2aa.cgi',
	[
	'dna_sequence'    => $dna_sequence,  
	'output_format'   => 'fasta'
 	]
);

my $aa=(split/\n/, $response->content)[1];
print "$aa\n";
#print ( $response->content );
