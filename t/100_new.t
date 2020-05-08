use strict;
use warnings;
use Test::More;

use Azure::Blob::SAS;

my $obj = new_ok('Azure::Blob::SAS',[
        sas_key        => $ENV{SAS_KEY},
        url            => $ENV{SAS_URL},
        #signedstart    => '2020-05-08T17:55:33Z',
        #signedexpiry   => '2020-05-09T01:55:33Z'
    ]
);


print "-\nSigned URL:\n";
print $obj->signed_url;
print "\n-\n-\n";

done_testing;
