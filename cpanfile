requires 'Moo';
requires 'Types::Standard';
requires 'URL::Encode';
requires 'Digest::SHA';
requires 'MIME::Base64';
requires 'DateTime';
requires 'DateTime::Format::ISO8601';
requires 'URI';
requires 'XML::LibXML';

on 'test' => sub {
    requires 'Test::More';
    requires 'LWP::UserAgent';
    requires 'Data::Printer';
    requires 'File::Temp';
    requires 'Digest::MD5';
    requires 'Text::Lorem::More';
    requires 'String::Random';
};
