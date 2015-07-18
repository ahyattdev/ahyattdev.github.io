#!/usr/bin/env perl

# Author: Patrick Muff <muff.pa@gmail.com>
# Purpose: Compiles a Cydia repository

use Digest::MD5;
 
sub md5sum {   
    my $file = shift;
    my $digest = "";
    eval {
        open(FILE, $file) or die "Can't find file $file\n";
        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        $digest = $ctx->hexdigest;
        close(FILE);
    };
    if ($@) {
        print $@;
        return ""; 
    }  
    return $digest;
}

system("cd ~/Documents/rossistboss.github.io");
system("pwd");

# scan the packages and write output to file Packages 
system("util/dpkg-scanpackages.pl debs / > Packages");

# bzip2 it to a new file 
system("bzip2 -fks Packages");

# gzip it  
system("gzip -f Packages");

# scan again because we zipped the original file  
system("util/dpkg-scanpackages.pl debs / > Packages");

# calculate the hashes and write to Release  
system("cp Release-Template Release");
open(RLS, ">>Release");

@files = ("Packages", "Packages.gz", "Packages.bz2");
my $output = "";

foreach (@files) {
 	my $fname = $_;
	my $md5 =  md5sum($fname);
	my $size = -s $fname;
	$output = $output.$md5." ".$size." ".$fname."\n";
};

print RLS $output;
close(RLS);

exit 0;
