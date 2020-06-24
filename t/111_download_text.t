use strict;
use warnings;
use Test::More;
use LWP::UserAgent;
use Data::Printer;
use File::Temp 'tempfile';
use Digest::MD5 'md5';

use Azure::Blob::SAS;

my $obj = Azure::Blob::SAS->new(
    sas_key        => $ENV{SAS_KEY},
    url            => $ENV{SAS_URL},
    #signedstart    => '2020-05-08T17:55:33Z',
    #signedexpiry   => '2020-05-09T01:55:33Z'
);

## Create a temp file for the download:
my $fh = tempfile( UNLINK => 1 );

## Download the file.
my $ua = LWP::UserAgent->new();
my $resp = $ua->get( $obj->signed_url, ':content_file' => $tmpfile );

is( $resp->code, 200, '200 response received for good URL');

## Get the md5 checksum for the file.
my $md5 = Digest::MD5->new;
$md5->addfile( $fh );

is ( 
    $md5->hexdigest,
    '820301c744b849579156669ec40a7bd0',
    "MD5 matches '820301c744b849579156669ec40a7bd0' for 'A simple text file.'"
);


done_testing;
