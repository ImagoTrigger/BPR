#!/usr/bin/perl

use common::sense;
use WebService::Discord::Webhook;

my $url = "https://discord.com/api/webhooks//";

print "$url\n";

my $webhook = WebService::Discord::Webhook->new( $url );
$webhook->get();
print "Webhook posting as '" . $webhook->{name} .
  "' in channel " . $webhook->{channel_id} . "\n";

$webhook->execute( content => $ARGV[0] );
