#########################################
# Copyright (C):2021
# File Name:run.pl
# Author:shikai
# Date:Sat 31 May 2025 06:36:59 PM CST
# Description:
# Modified by: shikai
# Email: shikai311@outlook.com
#########################################
#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path getcwd);
use File::Path qw(make_path);

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
my $prj_dir = $ENV{PRJ_DIR};
my $log_dir = undef;
my $test_dir = undef;
my $regression = undef;
my $sim_dir = undef;
my $com_dir = undef;
my $gui = undef;
my $comp_opt = " ";
my $novas = $ENV{VERDI_HOME}."/share/PLI/VCS/linux64/novas.tab";
my $PLI = $ENV{VERDI_HOME}."/share/PLI/VCS/linux64/pli.a";
my $UVM_SRC = $ENV{UVM_HOME}."/src";
my $UVM_PKG = $UVM_SRC."/uvm_pkg.sv";
my $UVM_HEADER = $UVM_SRC."/uvm_macros.svh";
my $cov_opt = "-cm line+cond+fsm+branch+tgl+assert";
#my $abs_path = undef;
my $common_sim_opt = "./simv +UVM_VERBOSITY=UVM_LOW +UVM_PHASE_TRACE +UVM_OBJECTION_TRACE";

GetOptions(
    "sim=s"             => \$simulation,
    "sd|sim_dir=s"      => \$sim_dir,
    "cd|com_dir=s"      => \$com_dir,
    "tc|testcase=s"     => \$testcase,    
    "c|compile"         => \$compile_only,
    "comp_opt=s"        => \$comp_opt,
    "all"               => \$compile_sim,
    "w|wave"            => \$waveform,     
    "cov"               => \$coverage,     
    "seed=i"            => \$seed,         
    "h|help"            => \$help, 
    "r|regress"         => \$regression,
    "g|gui"             => \$gui,
    "timescale=s"       => \$timescale,
    "d|debug"           => \$DEBUG,        
) or die "Error in command line arguments\n";

if ($help) {
    print_help();
    exit 0;
}

if($DEBUG){
    #read_rtl();
    #read_testbench();
    compile_file();
    #exit 0;
}

if(defined $com_dir and (defined $compile_only or defined $compile_sim)){
    unless(-e $com_dir){
        make_path($com_dir, {mode => 0755}) or die "can't create directry $com_dir: $!";
    } else {
        if(defined $DEBUG){
            print "already exist\n";
        }
    }
}elsif(defined $compile_only or defined $compile_sim){
    warn "Warning: Must Indicate Compile Files Location\n";
    exit 0;
}

if(defined $sim_dir and (defined $simulation or defined $compile_sim)){
    unless(-e $sim_dir){
        make_path($sim_dir, {mode => 0755}) or die "can't create directry $sim_dir: $!";
    } else {
        if(defined $DEBUG){
            print "already exist\n";
        }
    }
}elsif(defined $simulation or defined $compile_sim){
    warn "Warning: MUST Indicate Simulation Files Locatin\n";
    exit 0;
}

my $com_cmd = undef;
my $log_name = undef;
if($compile_only or $compile_sim or $DEBUG){  
    
    if(defined $testcase){
        $log_name = "/".$testcase.".log";
    }else{
        $log_name = "/compile.log";
    }
    $com_cmd = "vcs -full64 -sverilog +lint=PCWM +lint=TFIPC-L "."-timescale=$timescale "." -debug_acc+all "." -LDFLAGS -rdynamic -kdb -lca "."-P ".$novas." ".$PLI." -l $com_dir$log_name ".$comp_opt." +incdir+$UVM_SRC "." $UVM_PKG "." $UVM_HEADER ";       
    #print "$com_cmd\n";
    #print "seed=$seed\n";
}

my $sim_cmd;

if($compile_only){
    compile();
}elsif($simulation){
   simv();
}else{
    #run_sim();
}

sub compile{
    my @files;
    @files = compile_file();
    #print ("@files\n");
    my $cmd = $com_cmd." "."@files";
    #print("$cmd\n");
    #print "seed=$seed\n";
    system("$cmd |tee ./debug.log");
    #system("$cmd > ./sim$com_dir$log_name") or die "err : $!\n";
}

sub simv{
    if($simulation){
        if(defined $testcase){
            my $sim_log = undef;
            $sim_log = $sim_dir."/".$testcase."_".$seed.".log";
            $sim_cmd = $common_sim_opt." -l $sim_log ";
            $sim_cmd = $sim_cmd." +UVM_TESTNAME=$testcase"." +ntb_random_seed=$seed";
            if(defined $gui){
                $sim_cmd = $sim_cmd." +fsdb+autoflush -gui -verdi ";
            }elsif(defined $waveform){
                $sim_cmd = $sim_cmd."  +fsdbfile+$sim_dir/$testcase"."_$seed".".fsdb";
            }
            if(defined $DEBUG){
                print "$sim_cmd\n";
            }
            system($sim_cmd);
        }
    }
}

sub compile_file{
    if(defined $compile_only or defined $DEBUG ){
        my @files;
        @files = read_rtl(); 

        push @files, read_testbench();
        if(defined $DEBUG){
            print "@files\n";
        }
        return @files;
    }
} 

sub read_rtl {
    if(defined $ENV{PRJ_PATH}){
        $prj_dir = $ENV{PRJ_PATH};
        my ($filelist) = $prj_dir . '/de/filelist';
        my @files;
        if(defined $DEBUG){
            #print "$filelist \n";
        }
        open(my $fh, '<', $filelist) or die "Cannot open rtl filelist $filelist: $!\n";
        my $abs = abs_path(getcwd());
        #print "$abs\n";
        while (my $line = <$fh>) {
            chomp($line);
            next if ($line =~ /^\s*$/);
            next if ($line =~ /^\s*\/(\/){1,}/);
                     
            if($line =~ /\$\{(\w+)\}/){      
                $line =~ s/\$\{(\w+)\}/$ENV{$1}/eg;
                push @files, $line." ";
            }else{
                push @files, $abs."/.".$line." ";
            }
            if(defined $DEBUG){
                #print @files;
                #print "\n";
            }
        }
        close($fh);
        return @files;
    } else{
        warn "Warning: Please Initialize \$PRJ_PATH\n";
    }
}

sub read_testbench {
    if(defined $ENV{PRJ_PATH}){
        $prj_dir = $ENV{PRJ_PATH};
        my ($filelist) = $prj_dir . '/dv/filelist';
        my @files;
        if(defined $DEBUG){
            #print "$filelist \n";
        }
        open(my $fh, '<', $filelist) or die "Cannot open rtl filelist $filelist: $!\n";
        my $abs = abs_path(getcwd());
        #print "$abs\n";
        while (my $line = <$fh>) {
            chomp($line);
            next if ($line =~ /^\s*$/);
            next if ($line =~ /^\s*\/(\/){1,}/);
            if($line =~ /\$\{(\w+)\}/){      
                $line =~ s/\$\{(\w+)\}/$ENV{$1}/eg;
                push @files, $line." ";
            }else{
                push @files, $abs."/.".$line." ";
            }
            if(defined $DEBUG){
                #print @files;
                #print "\n";
            }
        }
        close($fh);
        return @files;
    } else{
        warn "Warning: Please Initialize \$PRJ_PATH\n";
    }
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
    -w,  --wave                  Enable waveform dumping
    -cv, --cov                   Enable coverage collection
    -s,  --seed <number>         Set random seed (default: current time)
    -h,  --help                  Print this help message
    -r,  --regress               Start Regression
    -d,  --debug                 Debug Mode

HELP
}


