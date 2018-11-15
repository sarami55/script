#!/usr/bin/env perl
use XML::Simple;
use Encode;
use LWP::Simple;

#####
# Radiko_id.pl
#     print station id
#
#		Radiko_id,pl 
#		or
#		Radiko_id.pl JPXX
#
#####


my ($ID)=@ARGV;

if ($ID eq "") {
	$URL="https://radiko.jp/v3/station/region/full.xml";
} else {
	$URL="https://radiko.jp/v3/station/list/$ID.xml";
}


$body = get($URL);
die "Couldn't get XML! Check AreaID" unless defined $body;

#print $body;

my $xml = XML::Simple->new();
my $data = $xml->XMLin($body);

if ($ID eq "") {
	for (my $i=0; $i<scalar(@{$data->{stations}}); $i++) {
		myprint($data->{stations}->[$i]->{station});
	}
} else {
		myprint($data->{station});
}

exit 0;

sub myprint() {
	my ($hash)=@_;
		while ((my $key, my $value) = each(%$hash)) {
			printf("%s", encode('UTF-8',$key));
			printf( " =  %s\n", $value->{id});
		}
}
