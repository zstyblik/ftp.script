#!/usr/bin/perl
# 2010/09/19 @ Zdenek Styblik
#
# Desc: strip everything except A-Za-z0-9_-.
#
use strict;
use warnings;
use File::Basename;

sub help {
	print <<HELP
	This is going to help!.
HELP
} # sub help

sub purifyFName {
	my $self = $_;
	my $string = shift;
	my @charArr = split(//, $string);
	my $newStr = '';

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
			if ($file eq '+upload') {
				next;
			} # if $file eq +upload
			my $newFile = &purifyFName($file);
			print "Diving into $newFile\n";
			&scanDir($newFile);
		} else {
			&purifyFName($file);
		} # if -d $file
	} # while $file
	chdir('../');
} # sub scanDir

if (!$ARGV[0]) {
	&help;
	exit 1;
} # if !$ARGV[0]

for my $argument (@ARGV) {
	if ( -d $argument ) {
		my $cwd = dirname($argument);
		my $dir = basename($argument);
		chdir($cwd);
		my $newDirName = &purifyFName($dir);
		print "Going to scan $newDirName\n";
		&scanDir($newDirName);
	} else {
		print &purifyFName($argument)."\n";
	} # else -d $argument
} # for $argument

1;
