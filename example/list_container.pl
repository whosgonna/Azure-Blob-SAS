#!/usr/bin/env perl

use strict;
use warnings;
use v5.30;
use Test::More;
use LWP::UserAgent;
use XML::LibXML;
use FindBin '$RealBin';
use lib "$RealBin/../lib";

use Data::Printer;

use Azure::Blob::SAS;



my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => 'https://whosgonna01.blob.core.windows.net/private1',
    signedpermissions => 'rcwdl',
    signedResource    => 'c',
);


say $obj2->signed_url . "\n";

my $ua = LWP::UserAgent->new();

#p $obj2->string_to_sign;

## Attempt to get the unsigned URL:
my $r = $ua->get( $obj2->signed_url . '&restype=container&comp=list&include=metadata' );

my $xml = $r->decoded_content;
my $dom = XML::LibXML->load_xml( string => $xml );

for my $blob ($dom->findnodes('//Blob')) {
    say 'Name:         ', $blob->findvalue('./Name');
    say 'Last-Modified ', $blob->findvalue('./Properties/Last-Modified' );
    say 'qqfilename    ', $blob->findvalue('./Metadata/qqfilename' );
    #for my $property ( $blob->findnodes( './Properties' ) ) {
    #   say $property->to_literal();
    #}
    say '';
}

