#!/usr/bin/perl
# 2010/09/19 @ Zdenek Styblik
#
# Desc: strip everything except A-Za-z0-9_-.
#
use strict;
use warnings;
use File::Basename;

sub help {
	printf("%s: script for clearing filenames of non-ASCII chars.\n");
	printf("Usage: %s <PATH>\n", $0);
	return 0;
} # sub help

sub purifyFName {
	my $self = $_;
	my $string = shift || undef;
	if (!$string) {
		return "";
	}
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
			printf("String is too short '%s'\n", $string);
			last;
		} # if length $newStr
		# do we have rw to $string ?
		if (! -w $string && ! -w './') {
			printf("No write permission to '%s'\n", $string);
			last;
		} # if ! -w $string
		printf("%s:%s\n", $string, $newStr);
		if ($string eq $newStr) {
			printf("Files are the same [%s:%s]\n", $string, $newStr);
			last;
		}
		# if $string =~ $newStr
		print "Will rename $string -> $newStr\n";
		rename($string, $newStr) or die("Couldn't rename f/d, '$!'\n");
		last;
	} # while 1
	return $newStr;
} # sub rename

sub scanDir {
	my $self = $_;
	my $dir2scan = shift;
	chdir($dir2scan) or die("Couldn't change dir, '$!'\n");
	opendir (DIR, '.') or die("Couldn't open directory, '$!'\n");
	my @files = grep { !/^\.{1,2}$/ } readdir (DIR);
	closedir DIR;
	foreach my $file (@files) {
		if (-d $file) {
			if ($file eq '+upload') {
				next;
			} # if $file eq +upload
			my $newFile = &purifyFName($file);
			printf("Diving into '%s'\n", $newFile);
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
		printf("Going to scan '%s'\n", $newDirName);
		&scanDir($newDirName);
	} else {
		my $newName = &purifyFName($argument);
		printf("%s\n", $newName);
	} # else -d $argument
} # for $argument

