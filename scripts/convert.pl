#!/usr/bin/perl -w

use strict;
use JSON::PP;

my $file = $ARGV[0];

open (FILE, $file) or die "Could not open $file: $!";

my @entries = ();
my $currentObjectRef = { };
my $content = "";

while (<FILE>) {
    print STDERR "Checking: $_";
    if ($_ =~ /^(\d+)\r$/) {
        # Start an entry
        print STDERR "Starting: $1\n";
        $currentObjectRef = {
            "entry" => $1,
        };
        push @entries, $currentObjectRef;
    } elsif ($_ =~ /(\d\d:\d\d:\d\d,\d\d\d) --> (\d\d:\d\d:\d\d,\d\d\d)/) {
        # Timecodes
        print STDERR "Timecodes: $1 -> $2\n";
        $$currentObjectRef{"start"} = getSeconds($1);
        $$currentObjectRef{"end"} = getSeconds($2);
    } elsif ($_ =~ /^\r$/) {
        # End an entry
        print STDERR "Ending entry\n";
        chomp $content;
        $$currentObjectRef{"content"} = $content;
        $currentObjectRef = { };
        $content = "";
    } elsif (%$currentObjectRef && $_ =~ /^(.+)\r$/) {
        # Must be text if in an entry
        print STDERR "Adding content: $1\n";
        $content .= $1 . "\n";
    }
}

close (FILE);

my $coder = JSON::PP->new->utf8;
my $output = $coder->encode(\@entries);

print $output;

sub getSeconds {
    my $input = shift;

    if ($input =~ /(\d\d):(\d\d):(\d\d),(\d\d\d)/) {
        my $hours = $1;
        my $minutes = $2;
        my $seconds = $3;
        my $mseconds = $4;

        my $retval = $seconds + ($minutes * 60) + ($hours * 60 * 60);
        $retval += $mseconds * 0.001;

        return $retval;
    } else {
        die "Bad input: '$input'";
    }
}
