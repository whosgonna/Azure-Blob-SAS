#!/usr/bin/env perl

## This example creates a signed URL for a CONTAINER, and then upload to an 
## abitraily named blob in that container.  This is less work than computing a 
## signature for each individual blob, with the trade off being security.
##
## NOTE about permissions
##
## c - Is "create".  The signed URL can be used to create a new object, but not
##     overwrite the object if it exists already.
## w - Is "write".  It will allow overwriting of 

use strict;
use warnings;
use v5.30;
use LWP::UserAgent;
use Data::Printer;
use FindBin '$RealBin';
use lib "$RealBin/../lib";
use Azure::Blob::SAS;
use String::Random 'random_regex';

## The root URL for the container.
my $container_url = 'https://whosgonna01.blob.core.windows.net/private1';

## Create the Shared Access Signature for the *container*
my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => $container_url,
    signedpermissions => 'rwl',           ## 'Read' and 'List' permissions
    signedResource    => 'c',            ## Note that this is a CONTAINER
);

## Print the signed URL for the root of the container.
say "URL: " . $obj2->signed_url . "\n";

##  We're trying to get a blob named "Simple.txt" from within this container.
my $name = random_regex('\w{10}') . '.txt';
say "File Name: $name";
my $url  = "$container_url/$name";

## The 'token' is the necessary components for the query.  Note that in some 
## cases (but not this case), we need to add additional arguments here.
my $token = $obj2->token;

## Append the tokent to the url for Simple.txt:
my $full_url = "$url?$token";

## Create our UserAgent and download the file:
my $ua = LWP::UserAgent->new();

my $r = $ua->put(
    $full_url,
    "x-ms-blob-type" => "BlockBlob",
    Content          => "Uploading to an arbitrary file name"
);

say "Response: " . $r->code . " - " . $r->message;

say "Trying to clobber the same file";

## Try clobbering it....
$r = $ua->put(
    $full_url,
    "x-ms-blob-type" => "BlockBlob",
    Content          => "Trying to clobber the same file.  Testing permissions",
);

say "Response: " . $r->code . " - " . $r->message;




