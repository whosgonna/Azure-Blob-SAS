use strict;
use warnings;
use Azure::Blob::SAS;


my $abs_obj = Azure::Blob::SAS->new(
        sas_key        => $ENV{SAS_KEY},
        url            => $ENV{SAS_URL},
);

my $signed_url = $abs_obj->signed_url;
