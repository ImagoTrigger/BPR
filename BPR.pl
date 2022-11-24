#!/usr/bin/perl
use common::sense;
use JSON;
use LWP::UserAgent::Determined;
use Storable;
use Number::Format 'format_number';
#use Proc::Pidfile;


$| = 1;

`renice 99 -p $$`;
sleep 15;
#my $pp = Proc::Pidfile->new( pidfile => "/home/pi/bpr.pid" );
print "started pid: - ".$$." - ". time . "\n";

my $skip = 0;
if (!-e '/home/pi/tweets.dat') {
        my @old = ();
        store \@old, '/home/pi/tweets.dat';
        $skip = 1;
}

my $browser = LWP::UserAgent::Determined->new;
$browser->timing( "1,3,5,10,15,20,25,30,35,40,45,50,60,70,80,90,120" );
my @old = @{retrieve('/home/pi/tweets.dat')};
while (1) {
my $url = "https://api.bscscan.com/api?module=account&action=tokentx&contractaddress=0x55e8d5ba6a859a4ff46f175bb3e7f003e16db821&address=0x7533a2968ffbb53cb0b08d6a3f5d5e6da51d87a5&startblock=0&endblock=9999999999999999&sort=desc&apikey=N4BRMUF9WXEDQARSZSZY8CZEESA75XA3UZ";
DONT:
my $response = $browser->get($url);
my $content;
if ($response->is_success) {
    $content=$response->decoded_content;
} else {
 goto DONT;
}
my $perl;
my @results;
if ($content) {
        $perl = decode_json $content;
         @results = @{$perl->{result}};
} else {
        @results = ();
}
my @txns = ();
foreach my $line (@results) {
   if ($line->{to} eq '0x55e8d5ba6a859a4ff46f175bb3e7f003e16db821') {
       #print $line->{transactionIndex} ."\n";
       push @txns, $line->{transactionIndex};
   }
}
my $tweet = "";
LINE: foreach my $line (@results) {
   if ($line->{to} ne '0x7533a2968ffbb53cb0b08d6a3f5d5e6da51d87a5' && $line->{to} ne '0x55e8d5ba6a859a4ff46f175bb3e7f003e16db821' && $line->{from} ne '0x55e8d5ba6a859a4ff46f175bb3e7f003e16db821' && $line->{from} ne '0x0000000000000000000000000000000000000000' && $line->{to} ne '0x0000000000000000000000000000000000000000') {
TX:       foreach my $txn (@txns) {
           if ($line->{transactionIndex} == $txn) {
               my $value = $line->{value};
               if (length $value > 9) {
                chop $value;chop $value;chop $value;chop $value;chop $value;chop $value;chop $value;chop $value;chop $value;
                $value = format_number($value);
               } else {
                   $value = "0.".$value;
               }
               my $check = $line->{hash};
                if ( grep( /^$check$/, @old ) ) {
                    #print "already tweeted ".$check."\n";
                } else {
                    #print $check ." - ".$value." - ".$line->{to}."\n";
                    $tweet = "New Buy ! 💸💸 https://bscscan.com/address/".$line->{to} . " bought $value BPR !! (Txn: https://bscscan.com/tx/$check)  🚀🔥🚀 #BusdPrinter";
                    push @old,$check;
                    store \@old, '/home/pi/tweets.dat';
                        my $cmd = "/home/pi/tweet.py \"$tweet\"";
                        print "execute: $cmd - " . time . "\n";
                        if (!$skip) {
                                my $r = `$cmd`;
                                print "$r\n";
                                my $tweet2 = "New Buy ! :money_with_wings::money_with_wings:  https://bscscan.com/address/".$line->{to} . " bought **$value BPR** !! (Txn: https://bscscan.com/tx/$check)  :rocket::fire::rocket: #BusdPrinter";
                                my $cmd = "/home/pi/discord.pl \"$tweet2\"";
                                my $r = `$cmd`;
                                sleep 1;
                        }
                }
           }
       }
   }
}
        $skip = 0;
    sleep 5;
}

print "done" .time."\n";
