#!/usr/bin/perl
# 2010/Jan/01 @ Zdenek Styblik
use strict;
use warnings;

sub purifyFName {
	my $self = $_;
	my $string = shift;
	my @charArr = split(//, $string);
	my $newStr = '';

	if ($string =~ /^\+./) {
		return $string;
	}

	my $arrSize = scalar @charArr;
	my @arrNewStr = qw();

	for (my $i = 0; $i < $arrSize; $i++) {
		if ($charArr[$i] =~ / /) {
			if ($charArr[$i+1] =~ / / || $arrNewStr[-1] =~ /\./) {
				next;
			} # if $charArr
			push(@arrNewStr, '.');
		} # if $charArr
		if ($charArr[$i] =~ /[A-Za-z0-9\.\_\-]/) {
			push(@arrNewStr, $charArr[$i]);
		} # if $charArr
		if ($charArr[$i] =~ /&/) {
			push(@arrNewStr, 'and');
		} # if $charArr =~
	} # for $i
	foreach (@arrNewStr) {
		$newStr = $newStr.$_;
	}
	while (1) {
		# what's the length of new string?
		if (length($newStr) < 1 && $newStr =~ /^[\.]+$/) {
			print "String is too short, $string\n";
			last;
		} # if length $newStr
		# do we have rw to $string ?
		if (! -w $string && ! -w './') {
			print "No write perm, $string\n";
			last;
		} # if ! -w $string
		print $string.":".$newStr."\n";
		if ($string eq $newStr) {
			print "Files are the same [$string:$newStr]\n";
			last;
		}
		# if $string =~ $newStr
		print "Will rename $string -> $newStr\n";
		rename($string, $newStr) or die "Couldn't rename f/d, $!\n";
		last;
	} # while 1
	return $newStr;
} # sub rename

sub scanDir {
	my $self = $_;
	my $dir2scan = shift;
	chdir($dir2scan) or die "Couldn't change dir, $!\n";
	opendir (DIR, '.') or die "Couldn't open directory, $!\n";
	my @files = grep { !/^\.{1,2}$/ } readdir (DIR);
	closedir DIR;
	foreach my $file (@files) {
		if (-d $file) {
			my $newFile = &purifyFName($file);
			print "Diving into $newFile\n";
			&scanDir($newFile);
		} else {
			&purifyFName($file);
		} # if -d $file
	} # while $file
	chdir('../');
} # sub scanDir

if ( -d $ARGV[0] ) {
	my $newDirName = &purifyFName($ARGV[0]);
	print "Going to scan $newDirName\n";
	&scanDir($newDirName);
} else {
	print &purifyFName($ARGV[0])."\n";
} # else -d $ARGV[0]

1;
