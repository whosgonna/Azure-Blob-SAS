#!/usr/bin/env perl

## This example creates a signed URL for a CONTAINER, and then downloads a 
## blob from that container.  This is less work than computing a signature
## for each individual blob.

use strict;
use warnings;
use v5.30;
use LWP::UserAgent;
use Data::Printer;
use FindBin '$RealBin';
use lib "$RealBin/../lib";
use Azure::Blob::SAS;


## The root URL for the container.
my $container_url = 'https://whosgonna01.blob.core.windows.net/private1';

## Create the Shared Access Signature for the *container*
my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => $container_url,
    signedpermissions => 'rl',           ## 'Read' and 'List' permissions
    signedResource    => 'c',            ## Note that this is a CONTAINER
);

## Print the signed URL for the root of the container.
say "URL: " . $obj2->signed_url . "\n";

##  We're trying to get a blob named "Simple.txt" from within this container.
my $url   = "$container_url/Simple.txt";

## The 'token' is the necessary components for the query.  Note that in some 
## cases (but not this case), we need to add additional arguments here.
my $token = $obj2->token;

## Append the tokent to the url for Simple.txt:
my $full_url = "$url?$token";

## Create our UserAgent and download the file:
my $ua = LWP::UserAgent->new();
my $r  = $ua->get( $full_url );

## Write the file contents.
say $r->decoded_content;



