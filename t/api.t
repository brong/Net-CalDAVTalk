#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use JSON::XS;
use Net::CalDAVTalk;

my $testdir = "testdata";

opendir(DH, $testdir);
my @list;
while (my $item = readdir(DH)) {
  next unless $item =~ m/(.*).ics/;
  push @list, $1;
}
closedir(DH);

plan tests => scalar(@list);

my $cdt = Net::CalDAVTalk->new(url => 'http://foo/');

foreach my $name (@list) {
  my $ical = slurp($name, 'ics');
  my $api = slurp($name, 'je');
  my @idata = $cdt->vcalendarToEvents($ical);
  die JSON::XS->new->pretty(1)->canonical(1)->encode(\@idata) unless $api;

  my $adata = JSON::XS::decode_json($api);

  is_deeply(\@idata, $adata, $name);
}

sub slurp {
  my $name = shift;
  my $ext = shift;
  open(FH, "<$testdir/$name.$ext") || return;
  local $/ = undef;
  my $data = <FH>;
  close(FH);
  return $data;
}
