#!perl
use strict;
use warnings;

use Test::More tests => 2;
use JSON::PP::Boolean;
use Net::CalDAVTalk;
use Data::Dumper;

my $event = {
          'isAllDay' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
          'participants' => {
                              'corion@example.com' => {
                                                                    'name' => 'corion@example.com',
                                                                    'roles' => [
                                                                                 'attendee'
                                                                               ],
                                                                    'scheduleRSVP' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
                                                                    'kind' => 'individual',
                                                                    'scheduleStatus' => 'needs-action',
                                                                    'email' => 'corion@example.com'
                                                                  },
                            },
          'created' => '2019-10-07T12:17:04Z',
          'title' => 'Example date',
          'sequence' => 0,
          'description' => 'RSVP field gets set to "0" instead of "FALSE"',
          'timeZone' => 'Etc/UTC',
          'method' => 'REQUEST',
          'start' => '2019-10-20T15:30:00'
        };

my $caldavtalk = bless {} => 'Net::CalDAVTalk';
my $vevent = $caldavtalk->_argsToVCalendar( $event );

my $entry = $vevent->entries->[0];
my $attendee = $entry->property('attendee')->[0];
my $rsvp = $attendee->parameters->{'RSVP'};

is $rsvp, "FALSE", "We encode the RSVP property as 'FALSE' in the data structure"
    or diag Dumper $rsvp;

my $vevent_str = $vevent->as_string();

$vevent_str =~ qr/\bRSVP\s*=([^:]+)\b/;
my $rsvp_value = $1;
like $rsvp_value, qr/^(TRUE|FALSE)$/, "and the RSVP property is TRUE or FALSE in the vevent string too"
    or diag $vevent_str;
