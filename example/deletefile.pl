#!/usr/bin/env perl

## This deletes the file created by uploadfile.pl.

use strict;
use warnings;
use v5.30;
use lib 'lib';
use LWP::UserAgent;
use Data::Printer;
use File::Temp;
use File::Basename;
use FindBin '$RealBin';
use Digest::MD5;

use Azure::Blob::SAS;



## Create signed URL.  This example hardcodes the name of the file to be 
## uploaded
my $upload_file = 'logo.png';
my $logofile    = "$RealBin/$upload_file";
my $url  = "https://whosgonna01.blob.core.windows.net/private1/logo.png";
my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => $url,
    signedpermissions => 'rcwd',
    signedResource    => 'b',
);

say $obj2->signed_url;

## Create the LWP useragent and upload
my $ua = LWP::UserAgent->new();


#  We're just putting raw binary block data.
my $r = $ua->delete(  $obj2->signed_url );
#    "x-ms-blob-type" => "BlockBlob", 
#    Content          =>  $data
#);
say "Response:  ${ \$r->code } - ${ \$r->message }";

exit;


