#!/usr/bin/env perl

#### I DON'T THINK THIS SCRIPT WORKS.

use strict;
use warnings;
use lib './lib/';
use Azure::Blob::SAS;
use LWP::UserAgent;

use v5.20;

## Tryign to upload to the root of my container (software-dist), but this looks
## like it is for the entire service.  Note the options of:
##
## ss = brqt  - SignedServices ( service_type ?)
##      b = Blob
##      r =  ?   (maybe file?  The example was generated with the azure control
#                 panel, and if i deselect 'file' the 'r' option disappears.
##      q = Queue
##      t = table
##      f = file (not present in this example).
##
## sp = rwdlacupx    - "signedpermissions"  Permissions
##      r - read: Valid for all signed resources types (Service, Container, and
##                  Object). Permits read permissions to the specified resource 
##                  type.
##      w - write: Valid for all signed resources types (Service, Container, and
##                  Object). Permits write permissions to the specified resource
##                  type.
##      d - delete: Valid for Container and Object resource types, except for 
##                  queue messages.
##      l - list:   Valid for Service and Container resource types only. 
##      a - add:    Valid for the following Object resource types only: queue 
##                  messages, table entities, and append blobs.
##      c - create: Valid for the following Object resource types only: blobs 
##                  and files. Users can create new blobs or files, but may not
##                  overwrite existing blobs or files.
##      u - update: Valid for the following Object resource types only: queue 
##                  messages and table entities.
##      p - process: Valid for the following Object resource type only: queue 
##                  messages 
##      x - blob versioning permissions
## 
## srt = o  - SignedResourceTypes
##      s - Service: Access to service-level APIs (e.g., Get/Set Service 
##          Properties, Get Service Stats, List Containers/Queues/Tables/Shares)
##      c - Container: Access to container-level APIs (e.g., Create/Delete 
##          Container, Create/Delete Queue, Create/Delete Table, Create/Delete 
##          Share, List Blobs/Files and Directories)
##      o - Object: Access to object-level APIs for blobs, queue messages, table
##          entities, and files(e.g. Put Blob, Query Entity, Get Messages, 
##          Create File, etc.)
##      You can combine values to provide access to more than one resource type.
##      For example, srt=sc specifies access to service and container resources.
## 


# ?sv=2019-10-10&ss=bfqt&srt=o&sp=rwdlacupx&se=2020-05-10T02:40:08Z&st=2020-05-09T18:40:08Z&spr=https&sig=%2BaBMzI7TOUMwp5Vk9go6ValHd%2B%2Bb3Ei%2BtpuvFvKnIqQ%3D
my $abs_obj = Azure::Blob::SAS->new(
        sas_key           => $ENV{SAS_KEY},
        url               => $ENV{SAS_URL},
        signedpermissions => 'rwacl'

);

my $signed_url = $abs_obj->signed_url;
#say $signed_url;
say $abs_obj->token;

my $az_version = '2019-10-10';
my $curl = "curl -v -X PUT -T ./{.gitignore} -H 'x-ms-date: $(date -u)' -H 'x-ms-blob-type: BlockBlob' -H 'x-ms-version: $az_version'  '$signed_url'";
say $curl;
