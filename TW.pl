#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Encode;
use Net::Twitter::Lite::WithAPIv1_1;
use Data::Dumper;

my %CONSUMER_TOKENS = (
    consumer_key    => 'ossUfDoHmZcqI2XSdgDhw',
    consumer_secret => 'ZBbLjd2gA28ySXru74047WFiMlDR3jGZ5TVhfg08sc',
    access_token    => '510460637-jdIDBslUkCvpNez657eyrErhsih1Z8o4tq3FwXiQ',
    access_token_secret => 'kWQZJk0KP1lFFZrREkJANr1D3UUkv5PzeYDCTtxtw',
    ssl		    => 1,
);

my $t = Net::Twitter::Lite::WithAPIv1_1->new(%CONSUMER_TOKENS);

my $text = $ARGV[0];
$text = decode( 'utf-8', $text );

my $status = $t->update({ status => $text });
print Dumper $status;
