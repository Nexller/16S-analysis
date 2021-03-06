#!/usr/bin/env perl
###############################################################################
#
#    uparse.to.otutable.pl
#
#	 Takes a .uc file and a sampleid file and makes an OTU table..
#    
#    Copyright (C) 2012 Mads Albertsen
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

#pragmas
use strict;
use warnings;

#core Perl modules
use Getopt::Long;

#locally-written modules
BEGIN {
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
}

# get input params
my $global_options = checkParams();

my $in;
my $out;
my $minsize;
my $reads;

$in = &overrideDefault("reads.fa",'in');
$out = &overrideDefault("dereplicated.fa",'out');
$minsize = &overrideDefault("2",'minsize');
$reads = &overrideDefault("reads.fa",'reads');
 
my %counts;
my $linecount = 0;
my $derepcount = 0;
my $seq = "";

######################################################################
# CODE HERE
######################################################################


### Read in the fasta file and stor all data in memory
open(in_fh, $in) or die("Cannot read file: $in\n");
open(reads_fh, ">$reads") or die("Cannot create file: $reads\n");

while ( my $line = <in_fh> ) {
	chomp $line;
     $linecount++;
	if ($line =~ m/>/) {
		if($linecount > 1){
			print reads_fh "$seq\n";
			if (exists($counts{$seq})){
				$counts{$seq}++;
			} else {
				$counts{$seq}++;
			}
		}
		$seq = "";
		print reads_fh "$line\n";

	}
	else{
		$seq = $seq.$line;
	}
}
print reads_fh "$seq\n";


close in_fh;
close reads_fh;

### Save the data to a file
open(out_fh, ">$out") or die("Cannot create file: $out\n");

foreach my $read (sort { $counts{$b} <=> $counts{$a} } keys %counts){
	if ($counts{$read} >= $minsize){
		$derepcount++;
		print out_fh ">d$derepcount;size=$counts{$read}\n";
		print out_fh "$read\n";
	}
}

close out_fh;


######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "in|i:s", "minsize|m:s", "out|o:s", "reads|r:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    exec("pod2usage $0") if (0 == (keys (%options) ));

    # If the -help option is set, print the usage and exit
    #
    exec("pod2usage $0") if $options{'help'};

    # Compulsosy items
    #if(!exists $options{'infile'} ) { print "**ERROR: $0 : \n"; exec("pod2usage $0"); }

    return \%options;
}

sub overrideDefault
{
    #-----
    # Set and override default values for parameters
    #
    my ($default_value, $option_name) = @_;
    if(exists $global_options->{$option_name}) 
    {
        return $global_options->{$option_name};
    }
    return $default_value;
}

__DATA__

=head1 NAME

    vprobes.generateprobes.pl

=head1 COPYRIGHT

   copyright (C) 2012 Mads Albertsen

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION



=head1 SYNOPSIS

uparse.to.dereplicate.pl -i [-h -o -m]

 [-help -h]      Displays this basic usage information
 [-in -i]        Reads to dereplicate in fasta format.
 [-minsize -m]   Minimum size of clusters (default: 2)
 [-out -o]       Dereplicated reads.
 [-reads -r]     All input reads exported in fasta format (default: reads.fa).
 
=cut
