#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';

my $VERSION = "0.1";

#kai-only
my $DEBUG = undef;

my $simulation = undef;      
my $top_module;
my $testcase = undef;
my $compile_only = undef;
my $run_only = undef;
my $compile_sim = undef;
my $clean = undef;
my $help = undef;
my $waveform = undef;
my $coverage = undef;
my $seed = time;
my $timescale = "1ns/1ps";
my $work_dir = undef;
my $log_dir = undef;
my $test_dir = undef;
my $regression = undef;
my $sim_dir = undef;
my $com_dir = undef;


GetOptions(
    "sim=s"             => \$simulation,
    "sd|sim_dir=s"      => \$sim_dir,
    "cd|com_dir=s"      => \$com_dir,
    "tc|testcase=s"     => \$testcase,    
    "c|compile"         => \$compile_only,
    "all"               => \$compile_sim,
    "r|run"             => \$run_only,     
    "w|wave"            => \$waveform,     
    "cov"               => \$coverage,     
    "seed=i"            => \$seed,         
    "h|help"            => \$help, 
    "r|regress"         => \$regression,
    "d|debug"           => \$DEBUG,        
) or die "Error in command line arguments\n";

if ($help) {
    print_help();
    exit 0;
}


sub print_help {
    print <<"HELP";
Usage: $0 [options]

Mandatory Environment Variables:
    RTL_FILELIST        Path to RTL file list
    TESTBENCH_LIST      Path to testbench file list
    WORK_PATH           Path to process simulation

Options:
    -sim,                        Simulation-Only
    -sd, --sim_dir               Directory to Simulation files
    -cd  --com_dir               Directory to Compile files
    -tc, --testcase <testcase>   Specify testcase to run
    -c,  --compile               Only compile RTL, don't run simulation
    -all,                        Compile then start simulation
    -r,  --run                   Only run simulation, don't compile
    -w,  --wave                  Enable waveform dumping
    -cv, --cov                   Enable coverage collection
    -s,  --seed <number>         Set random seed (default: current time)
    -h,  --help                  Print this help message
    -r,  --regress               Start Regression
    -d,  --debug                 Debug Mode

HELP
}
