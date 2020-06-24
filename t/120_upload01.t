use strict;
use warnings;
use Test::More;
use LWP::UserAgent;
use Data::Printer;

use Azure::Blob::SAS;


###########  This is an ACCOUNT SAS....  Further down for a SERVICE SAS. ##############
## This is the SAS for all(?) containers in the service.  How to generate.
#https://whosgonna01.blob.core.windows.net/?sv=2019-10-10&ss=b&srt=c&sp=rwdlacx&se=2020-06-01T01:00:00Z&st=2020-06-01T00:00:00Z&spr=https&sig=fTbH4IDqerWrsTXivsUYwoTUJytH3b%2B%2FKnEM7hMdFBI%3D
#
## This has:
#
## Allowed Services: Blob
## In URL:  ss=b
##
## Allowed Service Types: Container
## In URL: srt=c
##
## Allowed permissions:  Read, Write, Delete, List, Add, Create
## In URL:  sp=rwdlacx
#
## Blob Versioning Permissions: Enabled Deletoin of Versions
## In URL this is the "x" sp=rwdlacx



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

my $obj = new_ok('Azure::Blob::SAS',[
        sas_key           => $ENV{SAS_KEY},
        url               => 'https://whosgonna01.blob.core.windows.net/private1/Simple.txt',
        signedstart       => '2020-06-01T00:00:00Z',
        signedexpiry      => '2020-06-01T01:00:00Z',
        signedpermissions => 'rcwd',
        signedResource    => 'b',
    ]
);

#p $obj;
#p $obj->signed_url;
#p $obj->generate_signature;
#print "IhUHi0seBO3GiQnHqGRLsm0SnEVwBcJ%2FKNkejuE4zgs%3D\n";

my $obj2 = Azure::Blob::SAS->new(
    sas_key           => $ENV{SAS_KEY},
    url               => 'https://whosgonna01.blob.core.windows.net/private1',
    signedpermissions => 'rcwdl',
    signedResource    => 'c',
);

#p $obj2;

print "\n\n" . $obj2->signed_url . "\n\n";

#p $obj2->canonicalizedresource;

#my $res = $ua->post( $url, $field_name => $value, Content => \%form );

my $ua = LWP::UserAgent->new();
p $obj2->string_to_sign;
## Attempt to get the unsigned URL:
my $r = $ua->get( $obj2->signed_url . '&restype=container&comp=list' );
#my $r = $ua->put( $obj2->signed_url, "x-ms-blob-type" => "BlockBlob", Content => "Simple text file 2"  );
#p $r->request->headers;
p $r->decoded_content;
#is( $r->code, 200, '200 response received for good URL');

#p $r->decoded_content;

#is(
#    $r->decoded_content,
#    'A simple text file.',
#    "Content of received file is as expected"
#);

#my $txt = $ua->get( $obj->signed_url )->decoded_content;


done_testing;
