#!/usr/bin/perl -w

# If a repo has "security" in its name, then we're critical; else
# warning

use warnings;
use English;

my $check_name = "upgradeable_packages";


open(my $apt_fh, 'apt list --upgradable 2>/dev/null |') 
    or ( print("3 $check_name - Failed to open pipe from \"apt list\"\n") and exit(1) );

my @regular_updates;
my @security_updates;
while (my $line = <$apt_fh>) {
    if( $line =~ /^(.*)\/(\S+)/ ){
	my $package = $1;
	my $repos = $2;
	if( $repos =~ /security/i ){
	    push(@security_updates, $package);
	}
	else {
	    push(@regular_updates, $package);
	}
    };
}

if( @security_updates ){
    print("2 $check_name - Pending security updates: " . join(',', sort(@security_updates)) . "\n");
}
elsif( @regular_updates ){
    print("1 $check_name - Pending regular updates: " . join(',', sort(@regular_updates)) . "\n");
}
else {
    print("0 $check_name - No pending updates\n");
}

