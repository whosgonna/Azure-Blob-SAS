requires 'Moo';
requires 'Types::Standard';
requires 'URL::Encode';
requires 'Digest::SHA';
requires 'MIME::Base64';
requires 'DateTime';
requires 'DateTime::Format::ISO8601';
requires 'URI';

on 'test' => sub {
    requires 'Test::More';
};
