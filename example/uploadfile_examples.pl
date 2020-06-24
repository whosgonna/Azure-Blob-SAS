#!/usr/bin/env perl

use strict;
use warnings;
use v5.30;
use lib 'lib';
use Test::More;
use LWP::UserAgent;
use Data::Printer;
use File::Temp;
use Text::Lorem::More;
use File::Basename;
use FindBin '$RealBin';

use Azure::Blob::SAS;


######### This is a SERVICE SAS. It should be limited to the container (the service)
## https://whosgonna01.blob.core.windows.net/private1/Simple.txt?sp=rcwd&st=2020-06-01T00:00:00Z&se=2020-06-01T01:00:00Z&spr=https&sv=2019-10-10&sr=b&sig=IhUHi0seBO3GiQnHqGRLsm0SnEVwBcJ%2FKNkejuE4zgs%3D
#
## This has
##
## Allowed Permissions: Read, Create, Write, Delete
## In URL:  sp=rcwd
## 
## Start Time: 2020-06-01T00:00:00Z
##
## Expiry Time: 2020-06-01T01:00:00Z
##
## Signed Resource: b
## In URL:  sr=b
##
## Also present in the URL:
##
## spr=https     - Signed Protocol:  https
## sv=2019-10-10 - Signed Version:  2019-10-10 (this is the API version).


### Generate random data to temporary file
my $lorem    =  Text::Lorem::More->new;
my $txt      = $lorem->paragraphs(3);
my $tempfile = File::Temp->new( UNLINK => 1 );

open( my $fh, '>:encoding(UTF-8)', $tempfile );
print $fh $txt;
close $fh;
my $full_filename             = $tempfile->filename;
my ( $short_filename, $path ) = fileparse( $full_filename );

## Create signed URL.  This example hardcodes the name of the file to be 
## uploaded
my $upload_name = "$short_filename.txt";
$upload_name    = 'logo.png';
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
my $logofile = "$RealBin/logo.png";
open( my $newfh, '<', $logofile
);
binmode $newfh;
my $data = do { local $/; <$newfh> };
close $newfh;


my $r = $ua->put( 
    $obj2->signed_url, 
    "x-ms-blob-type" => "BlockBlob", 
    #':content_file'  => $full_filename,
    #Content_Type     => 'form-data',
    #Content_Type     => 'application/octet-stream',
    Content          =>  $data
);
p $r;
#p $r->decoded_content;
#is( $r->code, 200, '200 response received for good URL');

#p $r->decoded_content;

#is(
#    $r->decoded_content,
#    'A simple text file.',
#    "Content of received file is as expected"
#);

#my $txt = $ua->get( $obj->signed_url )->decoded_content;


done_testing;
