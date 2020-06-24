#!/usr/bin/env perl

## Whereas uploadfile.pl creates a signed URL for the blob (this includes the 
## file name to be used), this is an attempt to create a signed URL for the
## container, and then allow uploading of any arbitray file.

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


## NOTE: We need to upload the file CONTENTS, not the file.  Multi-part uploading
## seems to not work.  This is a somewhat convoluted example, because we earlier
## created a new lorem ipsum _file_, and now we're re-reading that file.
open( my $fh, '<', $logofile ) 
    or die "Failed opening $logofile: $_";
binmode $fh;

## Slurp the binary file in here.  This might not be the best idea for large files.
my $data = do { local $/; <$fh> };

## Get the md5 before closing the filehandle:
my $d1 = Digest::MD5->new;
$d1->addfile( $fh );
close $fh;

#  We're just putting raw binary block data.
my $r = $ua->put( 
    $obj2->signed_url, 
    "x-ms-blob-type" => "BlockBlob", 
    Content          =>  $data
);
say "Response:  ${ \$r->code } - ${ \$r->message }";


## Now try downloading the file
$r = $ua->get( $obj2->signed_url );

## Create the output file handle and write the data:
my $outfile = "$RealBin/2logo.png";
open( my $fh2, '+>', $outfile )
    or die "Failed to open output file $outfile: $_";
my $data2 = $r->decoded_content( charset => 'none' );
print $fh2 $data2;

## Get the md5 before closing the filehandle:
my $d2 = Digest::MD5->new;
$d2->addfile( $fh2 );
close $fh2;

## Compare the files:
say "Original md5hex:   " . $d1->hexdigest;
say "Downloaded md5hex: " . $d2->hexdigest;





