#!/usr/bin/env perl

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


# https://whosgonna01.blob.core.windows.net/private1/1100c447-68de-445d-9075-7be252c3d9e7.exe?
#   se=2020-06-23T20:57:09Z&
#   sig=xmIgzycI%2B3HxW1BBmWhYd6mS3UMh5HfvKYVHllHt1kI%3D&
#   sp=w&
#   spr=https&
#   sr=b&
#   st=2020-06-23T20:42:09Z&
#   sv=2019-10-10

my $file_name = '1100c447-68de-445d-9075-7be252c3d9e7.exe';
## Create signed URL.  This example hardcodes the name of the file to be 
## uploaded
my $upload_file = 'logo.png';
my $logofile    = "$RealBin/$upload_file";
my $url  = "https://whosgonna01.blob.core.windows.net/private1/$file_name";
my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => $url,
    signedpermissions => 'w',
    signedResource    => 'b',
    signedstart       => '2020-06-23T20:42:09Z',

);

say $obj2->signed_url;

say $obj2->generate_signature;
say 'xmIgzycI%2B3HxW1BBmWhYd6mS3UMh5HfvKYVHllHt1kI%3D';
exit;
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





