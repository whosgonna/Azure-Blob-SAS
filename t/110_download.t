use strict;
use warnings;
use Test::More;
use LWP::UserAgent;
use Data::Printer;

use Azure::Blob::SAS;

my $obj = new_ok('Azure::Blob::SAS',[
        sas_key        => $ENV{SAS_KEY},
        url            => $ENV{SAS_URL},
        #signedstart    => '2020-05-08T17:55:33Z',
        #signedexpiry   => '2020-05-09T01:55:33Z'
    ]
);


my $ua = LWP::UserAgent->new();

## Attempt to get the unsigned URL:
my $unsigned_r = $ua->get( $ENV{SAS_URL} );

is ( 
    $unsigned_r->code,
    404,
    "Unsigned rquest returned 404 not found"
);

my $r = $ua->get( $obj->signed_url );

is( $r->code, 200, '200 response received for good URL');

is(
    $r->decoded_content,
    'A simple text file.',
    "Content of received file is as expected"
);

#my $txt = $ua->get( $obj->signed_url )->decoded_content;


done_testing;
