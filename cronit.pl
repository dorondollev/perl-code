#!/usr/bin/perl -w
use strict;
use Date::Calc qw(:all);
use Math::BigInt;
##################### DECLARATIONS #############################
#open (PH, "crontab") || die;
my @cron;
my %week_days =  ('Mon' => 0, 'Tue' => 1, 'Wed' => 2, 'Fri' => 3, 'Thu' => 4, 'Sat' => 5, 'Sun' => 6);
my $job_key;
my $job_body;
my @job_moment;
my ($size,$mod,$parity);
my ($server,$user,$job,$password);
my (@date,@time,@start_date,@end_date);
my @job_month_out = ();
my @job_month_day_out = ();
my @job_hour_out = ();
my @job_min_out = ();
my %hash_job;
my (@job_min,@job_hour,@job_month_day,@job_month,@job_week_day);
my (@start_time,$start_min,$start_hour,$start_month_day,$start_month,$bwday,$start_year);
my (@end_time,$end_min,$end_hour,$end_month_day,$end_month,$ewday,$end_year);
my (%arg);
my @local_time_arr;
my $local_time;
my $str_year;
my @cronin;
my $remote;
my $file="crontab";
my (@job_rules,@cron_rules);
##############################################################

################### PARAMETERS BEGIN ########################
### Parse input parameters ###

if ((join('',@ARGV)) eq '-h') {
    &print_help;
    exit;
}
if (scalar @ARGV==0) {
    &print_help;
    exit;
}

my $action=$ARGV[0];
my @arguments=@ARGV[1..$#ARGV];

%arg=@arguments;
foreach my $arg_key (keys(%arg)) {
    if ( $arg_key eq '-d' or
        $arg_key eq '-t' or
        $arg_key eq '-s' or
        $arg_key eq '-u' or
        $arg_key eq '-p'or
        $arg_key eq '-f') {
    } else {
        die "\nInvalid parameters: $!";
    }
}

### Time parameter handling ###
if (exists($arg{"-t"})) {
    @time = split ('-',$arg{"-t"});
    @start_time = split (':',$time[0]);
    $start_hour = $start_time[0];
    $start_min = $start_time[1];
    if (defined $time[1]) {
        @end_time = split(':',$time[1]);
        $end_hour = $end_time[0];
        $end_min = $end_time[1];
    } else {
        $end_hour = $start_hour;
        $end_min = $start_min;
    }
} else {
    $start_hour=00;
    $end_hour=23;
    $start_min=00;
    $end_min=59;
}

$start_hour = &two_digit($start_hour);
$end_hour = &two_digit($end_hour);
$start_min = &two_digit($start_min);
$end_min = &two_digit($end_min);

### Date parameter handling ###
@local_time_arr=split(' ',localtime (time));
$start_year=$local_time_arr[4];
if (exists($arg{"-d"})) {
    @date = split ('-',$arg{"-d"});
    @start_date = split('/',$date[0]);
    $start_month = $start_date[1];
    $start_month_day = $start_date[0];
    if (defined $date[1]) {
        @end_date = split('/',$date[1]);
        $end_month = $end_date[1];
        $end_month_day = $end_date[0];
        if ($start_month>$end_month) {$end_year=$start_year+1;} else {$end_year=$start_year;}
    } else {
        if ((join('',$start_hour,$start_min)) > (join('',$end_hour,$end_min))) {
            ($end_year,$end_month,$end_month_day) = Add_Delta_Days($start_year,$start_month,$start_month_day,1);
        } else {
            $end_year=$start_year;
            $end_month = $start_month;
            $end_month_day = $start_month_day;
        }
    }
} else {
    $start_month=Decode_Month($local_time_arr[1]);
    $start_month_day=$local_time_arr[2];
    if ((join('',$start_hour,$start_min)) > (join('',$end_hour,$end_min))) {
        ($end_year,$end_month,$end_month_day) = Add_Delta_Days($start_year,$start_month,$start_month_day,1);
    } else {
        $end_year=$start_year;
        $end_month=$start_month;
        $end_month_day=$start_month_day;
    }
}
$start_month = &two_digit($start_month);
$end_month = &two_digit($end_month);
$start_month_day = &two_digit($start_month_day);
$end_month_day = &two_digit($end_month_day);

if (exists($arg{"-s"})) {
    $server=$arg{"-s"};
    $remote=1;
} else {
    $server=`hostname`;
    $remote=0;
}

if (exists($arg{"-f"})) {
    $file=$arg{"-f"};
    $remote=2;
}

if (exists($arg{"-u"})) {
    $user=$arg{"-u"};
}

### Parameters verification ###
$action=~/^\w+$/ || die "\nInvalid action name: $!\n";
$start_month=~/^\d\d$/ || die "\nInvalid month number: $!\n";
$end_month=~/^\d\d$/ || die "\nInvalid month number: $!\n";
$start_month_day=~/^\d\d$/ || die "\nInvalid month day number: $!\n";
$end_month_day=~/^\d\d$/ || die "\nInvalid month day number: $!\n";
$start_hour=~/^\d\d$/ || die "\nInvalid hour number:$!\n";
$end_hour=~/^\d\d$/ || die "\nInvalid hour number:$!\n";
$start_min=~/^\d\d$/ || die "\nInvalid minutes number: $!";
$end_min=~/^\d\d$/ || die "\nInvalid minutes number: $!";

if (defined $server) {$server=~/^[\w|\.|_]+$/ || die "\nInvalid server name: $!";}
if (defined $user) {$user=~/^\w+$/ || die "\nInvalid user name: $!";}
if (defined $password) {$password=~/\w+/||die "\nInvalid password:$!";}

############################## PARAMETERS END ####################################

### Get crontab file ###
if ($remote==1) {
    if (defined $user) {
        @cronin=`rsh -l $user $server crontab -l`;
    } else {
        @cronin=`rsh $server crontab -l`;
    }
} elsif ($remote==2) {
    open(CRONIN,$file) || die "Unable to open $file";
    @cronin=<CRONIN>;
    close (CRONIN);
} else {
    @cronin=`crontab -l`;
}

### Get job rules array ###
my $flag_job_rules=0;
my @cronin_copy=@cronin;
foreach my $str (@cronin_copy) {
    chomp $str;
    if ($str =~/^\#\{/) {        #Rules string
        $flag_job_rules=1;
        ### Default rules ### (name,description,contact,duration,skip,shift,before,after,not_with,window)
        @job_rules=("NoName","NoDescription","NoContact","30","n","0","","","","*");
        $str=~s/\#\{//;
        $str=~s/\}//;
        my $orig_param_str=$str;
        my @parts=split /\'/,$str;
        my $quoted_string=0;
        foreach my $part (@parts) {
            $quoted_string++;
            if ($quoted_string==2)  {
                $part=~s/\s/|/g;
                $quoted_string=0;
            }
        }
        if ($quoted_string==0) {
            print "\nSYNTAX ERROR in the following string: \n $orig_param_str \nProcess ABORTED!!!\n";
            exit 1;
            }
        $str=join ('',@parts);
        $str=~s/\=/ /g;
        my %rules=split(' ',$str);
        foreach my $key (keys(%rules)) {
            if ($key eq 'name') {$job_rules[0]=$rules{$key}}
            elsif ($key eq 'description') {$job_rules[1]=$rules{$key}}
            elsif ($key eq 'contact') {$job_rules[2]=$rules{$key}}
            elsif ($key eq 'duration') {$job_rules[3]=$rules{$key}}
            elsif ($key eq 'skip') {$job_rules[4]=$rules{$key}}
            elsif ($key eq 'shift') {$job_rules[5]=$rules{$key}}
            elsif ($key eq 'before') {$job_rules[6]=$rules{$key}}
            elsif ($key eq 'after') {$job_rules[7]=$rules{$key}}
            elsif ($key eq 'not_with') {$job_rules[8]=$rules{$key}}
            elsif ($key eq 'window') {$job_rules[9]=$rules{$key}}
            else {print "\nSYNTAX ERROR: Unknown parameter $key in the following string: \n $orig_param_str \nProcess ABORTED!!!\n";exit 1;}
            $job_rules[0]=~/^\w+$/ || die "\nSyntax error: invalid job name in $orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[1]=~/^.+$/ || die "Syntax error: invalid description in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[2]=~/^$|^\w+$|^\'(\,*\w+\s*)*\'$/ || die "Syntax error: invalid contact in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[3]=~/^$|^\d{1,4}$/ || die "Syntax error: invalid duration in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[4]=~/^$|^[yYnN]$/ || die "Syntax error: invalid skip value in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[5]=~/^$|^[\+\-]{0,1}\d{1,4}$/ || die "Syntax error: invalid shift value in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[6]=~/^$|^\w+(,\w+)*$/ || die "Syntax error: invalid before name in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[7]=~/^$|^\w+(,\w+)*$/ || die "Syntax error: invalid after name in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[8]=~/^$|^\w+(,\w+)*$/ || die "Syntax error: invalid not_with name in \n$orig_param_str\nProcess ABORTED!!!\n";
            $job_rules[9]=~/\*|^\d{1,2}\-\d{1,2}(\,\d{1,2}\-\d{1,2})*$/ || die "Syntax error: invalid window in \n$orig_param_str\nProcess ABORTED!!!\n";
        }
    } elsif ($str =~/^\s*\d/) {      #job string
        if ($flag_job_rules==1) {          #this string is after rules string
            $job_body = &get_job_body($str);
            my @sched_params=split ('\s+',$str);
            (@job_rules[10..15])=(@sched_params[0..4],$job_body);
            $flag_job_rules=0;
            push @cron_rules,join (':',@job_rules);
        } else {        #string without rules
            ### Default rules ### (name,description,contact,duration,skip,shift,before,after,not_with,window)
            @job_rules=("NoName","NoDescription","NoContact","30","n","0","","","","*");
            $job_body=&get_job_body($str);
            my @sched_params=split ('\s+',$str);
            (@job_rules[10..15])=(@sched_params[0..4],$job_body);
            $flag_job_rules=0;
            push @cron_rules,join(':',@job_rules);
        }
    } else {    #ignore the string
        1;
    }
}       #End string handling


############################## SHOW handling begin ##################################

if ($action eq "show") {
    foreach my  $str (@cronin) {
        chomp $str;
        if (not ($str =~/^\#/ or $str=~/^\s+$/)) {
        push @cron,$str;
        }
    }
    #print "\n\@cron: ",join('|',@cron);

    ### Print header ###
    print "\n=============================================================================================================";
    print "\nComputer: $server";
    print "\nScheduled jobs during the displayed period:";
    print "\nFrom:  ",$start_month_day,"/", $start_month,"/",$start_year,"  ", $start_hour,":",$start_min;
    print "\nTo:    ",$end_month_day,"/",$end_month,"/",$end_year,"  ",$end_hour,":",$end_min;
    print "\n=============================================================================================================\n";

    my $line =1000;
    foreach my $str_cron (@cron) {
        $line ++;
        @job_moment = split('\s+',$str_cron);
        $job_body = &get_job_body($str_cron);
        my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
        my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
        my @job_recur=(@job_moment[0..4]);
        my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
        foreach my $str (@job_instances) {
            my @times_arr = split (':',$str);
            (my $year,my $month,my $month_day,my $hour,my $min)=@times_arr;
            $job_key = join('',$year,$month,$month_day,$hour,$min,$line);
            my $job_body_disp = join('',$month_day,'/',$month,'  ',$hour,':',$min,'   ',$job_body);
            $hash_job{$job_key} = $job_body_disp;
        }
    }
    ### Printing Jobs ###
    foreach my $str_val (sort {$a<=>$b} keys %hash_job) {
        print "\n",$hash_job{$str_val};
    }

############################## SHOW end ####################################

############################## CHECK begin ##################################

} elsif ( $action eq "check" ) {

    ### Print header ###
    print "\n=============================================================================================================";
    print "\nComputer: $server";
    print "\nCheck crontab rules during the displayed period:";
    print "\nFrom:  ",$start_month_day,"/", $start_month,"/",$start_year,"  ", $start_hour,":",$start_min;
    print "\nTo:    ",$end_month_day,"/",$end_month,"/",$end_year,"  ",$end_hour,":",$end_min;
    print "\n=============================================================================================================\n";

    ### NOT_WITH check ###
    foreach my $str (@cron_rules) {
        chomp $str;
        my @job_rules=split(':',$str);
        if (defined($job_rules[8])) {
            my @not_with_list;
            my @list=split (',',$job_rules[8]);
            foreach my $str(@list) {
                if (not (scalar (grep /^$str:/,@cron_rules) + scalar (grep /^${str}_shifted:/,@cron_rules))) {
                    print "\nWarning: the not_with=$str referenced by $job_rules[0] not found";
                }
                my $job=$job_rules[0];
                push @not_with_list,$str;
                push @not_with_list,$str."_shifted";
                if ($job_rules[0]!~/_shifted/) {
                    push @not_with_list,$job."_shifted";
                } else {
                    $job=~s/_shifted//;
                    push @not_with_list,$job;
                }
            }
            foreach my $not_with_name (@not_with_list) {
               if (not grep /^$not_with_name:/,@cron_rules) {
                    next;
                }
                my @not_with_job=split(':',join('',grep($_=~/^$not_with_name:/,@cron_rules)));
                my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
                my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
                my @job_recur=($job_rules[10],$job_rules[11],$job_rules[12],$job_rules[13],$job_rules[14]);
                #instances of the checked job in check period:
                my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
                foreach my $job_instance (@job_instances) {
                    #job moment - duration of "not_wit job":
                    my @start_moment=&add_delta_time(-$not_with_job[3],(split(':',$job_instance))[0..4]);
                    #job moment + duration of the job:
                    my @end_moment=&add_delta_time($job_rules[3],(split(':',$job_instance))[0..4]);
                    my @job_recur=@not_with_job[10..14];
                    my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
                    if (scalar @job_instances >0) {
                        print "\nWarning: there is overlapping between jobs: $job_rules[0] and $not_with_name";
                        last;
                    }
                }
            }
        }
    }
    ### time WINDOW check ###
    foreach my $str (@cron_rules) {
        chomp $str;
        my @job_rules=split(':',$str);
        if (defined($job_rules[9]) and $job_rules[9] ne "*") {
            my @windows=split (',',$job_rules[9]);
            foreach my $window (@windows) {
                my @arr=split '-',$window;
                $arr[1]--;
                $arr[1]=23 if ($arr[1]==-1);
                $window=join '-',@arr;
                1;
            }
            #instances in the check period:
            my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
            my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
            my @job_recur=(@job_rules[10..14]);
            my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
            my @allowed=&get_job_times(join(',',@windows),0,23);
            my @day_hours=qw (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
            my $pattern=join('|',@allowed);
            my @prohibited=grep !/$pattern/,@day_hours;
            my @job_hours;
            foreach my $job_str (@job_instances) {
                my @start_instance=split (':',$job_str);
                my @end_instance=&add_delta_time($job_rules[3],@start_instance);
                if ($start_instance[2] = $end_instance[2]) { # job do not slides to the next day
                    for (my $j=$start_instance[3];$j<=$end_instance[3];$j++) {    #hours loop
                        push(@job_hours,&two_digit($j));
                    }
                } else {
                    for (my $j=$start_instance[3];$j<24;$j++) {    #hours loop
                        push(@job_hours,&two_digit($j));
                    }
                    for (0;my $j<=$end_instance[3];$j++) {    #hours loop
                        push(@job_hours,&two_digit($j));
                    }
                }
            }
            $pattern=join('|',@prohibited);
            my @bad_hours=grep /$pattern/,@job_hours;
            if (scalar @bad_hours>0) {
                print "\nWarning: the job $job_rules[0] runs out of allowed time window";
            }
        }
    }
    ### BEFORE check ###
    foreach my $str (@cron_rules) {
        chomp $str;
        my @job_rules=split(':',$str);
        if (defined($job_rules[6])) {
            my $proxy_interval=&get_proxy_interval(@job_rules[10..14]);
            my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
            my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
            my @job_recur=(@job_rules[10..14]);
            my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
            foreach my $before_name (split(',',$job_rules[6])) {
                if (not (scalar (grep /^$before_name:/,@cron_rules) + scalar (grep /^${before_name}_shifted:/,@cron_rules))) {
                    print "\nWarning: the before=$before_name referenced by $job_rules[0] not found";
                }
                if (not grep /^$before_name:/,@cron_rules) {
                    next;
                }
                my @before_rules=split(':',join('',grep(/^$before_name:/,@cron_rules)));
                foreach my $job_instance (@job_instances) {
                    my @before_start_moment=(&add_delta_time($job_rules[3],split(':',$job_instance)));
                    my @before_end_moment=(&add_delta_time($proxy_interval,@before_start_moment));
                    my @before_recur=(@before_rules[10..14]);
                    my @before_instances=&get_job_instances(\@before_start_moment,\@before_end_moment,\@before_recur);

                    my @before_shifted_instances;
                    if (grep /^${before_name}_shifted:/,@cron_rules) {   #if exists shifted?
                        my @before_shifted_rules=split(':',join('',grep(/^${before_name}_shifted:/,@cron_rules)));
                        my @before_shifted_recur=(@before_shifted_rules[10..14]);
                        my @before_shifted_instances=&get_job_instances(\@before_start_moment,\@before_end_moment,\@before_shifted_recur);
                    }
                    if (scalar @before_instances + scalar @before_shifted_instances==0) {
                        print "\nWarning: job $job_rules[0] doesn't run before any instance of job $before_rules[0] ";
                        print "(or $before_rules[0]_shifted)";
                        last;
                    } elsif (scalar @before_instances + scalar @before_shifted_instances > 1) {
                        print "\nWarning: There are more than one instances of job $before_rules[0] ";
                        print "(or $before_rules[0]_shifted) running after job $job_rules[0]";
                        last;
                    } else {
                        1;
                    }
                }
            }
        }
    }

    ### AFTER check ###
    foreach my $str (@cron_rules) {
        chomp $str;
        my @job_rules=split(':',$str);
        if (defined($job_rules[7])) {
            my $proxy_interval=&get_proxy_interval(@job_rules[10..14]);
            my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
            my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
            my @job_recur=(@job_rules[10..14]);
            my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
            foreach my $after_name (split(',',$job_rules[7])) {
                if (not (scalar (grep /^$after_name:/,@cron_rules) + scalar (grep /^${after_name}_shifted:/,@cron_rules))) {
                    print "\nWarning: the after=$after_name referenced by $job_rules[0] not found";
                }
                if (not grep /^$after_name:/,@cron_rules) {
                    next;
                }
                my @after_rules=split(':',join('',grep(/^$after_name:/,@cron_rules)));
                foreach my $job_instance (@job_instances) {
                    my @after_end_moment=split(':',$job_instance) ;
                    my @after_start_moment=(&add_delta_time(-($after_rules[3]+$proxy_interval),@after_end_moment));
                    my @after_recur=(@after_rules[10..14]);
                    my @after_instances=&get_job_instances(\@after_start_moment,\@after_end_moment,\@after_recur);

                    my @after_shifted_instances;
                    if (grep /^${after_name}_shifted:/,@cron_rules) {   #if exists shifted?
                        my @after_shifted_rules=split(':',join('',grep(/^${after_name}_shifted:/,@cron_rules)));
                        my @after_shifted_recur=(@after_shifted_rules[10..14]);
                        @after_shifted_instances=&get_job_instances(\@after_start_moment,\@after_end_moment,\@after_shifted_recur);
                    }
                    if (scalar @after_instances + scalar @after_shifted_instances==0) {
                        print "\nWarning: job $job_rules[0] doesn't run after any instance of job $after_rules[0] ";
                        print "(or $after_rules[0]_shifted)";
                        last;
                    } elsif (scalar @after_instances + scalar @after_shifted_instances > 1) {
                        print "\nWarning: There are more than one instances of job $after_rules[0] ";
                        print "(or $after_rules[0]_shifted) running before job $job_rules[0]";
                        last;
                    } else {
                        1;
                    }
                }
            }
        }
    }

################################ CHECK end #############################
############################## SHIFT begin ##################################

} elsif ( $action eq "shift" ) {
    my @skipout = @cronin;
    my @shiftout = @cronin;
    my @append;
    open (CRONOUT,">$file.out");
    ### Print header ###
    print "\n=============================================================================================================";
    print "\nComputer: $server";
    print "\nShifting scheduled jobs...";
    print "\nShutdown interval:";
    print "\nFrom:  ",$start_month_day,"/", $start_month,"/",$start_year,"  ", $start_hour,":",$start_min;
    print "\nTo:    ",$end_month_day,"/",$end_month,"/",$end_year,"  ",$end_hour,":",$end_min;
    print "\n=============================================================================================================\n";

    foreach my  $str (@cron_rules) {
        chomp $str;
        my @job_rules=split(':',$str);
        my @start_moment=($start_year,$start_month,$start_month_day,$start_hour,$start_min);
        @start_moment=&add_delta_time(-$job_rules[3],@start_moment);
        my @end_moment=($end_year,$end_month,$end_month_day,$end_hour,$end_min);
        my @job_recur=(@job_rules[10..14]);
        my @job_instances=&get_job_instances(\@start_moment,\@end_moment,\@job_recur);
        1;
        if (scalar @job_instances > 0) {    #there is job in shutdown period?

            ### SKIP ###
            if ($job_rules[4] eq "y" or $job_rules[4] eq "Y") {      #skip=y?
                my @job_hours_dirty;
                foreach (@job_instances) {
                    push @job_hours_dirty,(split ':',$_)[3];
                }
                my @job_hours=&get_job_times($job_rules[11],0,23);
                my $pattern=join('|',@job_hours_dirty);
                my @job_hours_clean=grep !/$pattern/,@job_hours;
                my $new_hours=&get_sched_str(@job_hours_clean);
                my $thats_it=0;
                foreach(@skipout) {
                    next if /^$/;
                    chomp;
                    if ($new_hours eq "") {    #no runs.
                        if (/^\#\{\s*name=$job_rules[0] /) { #rules of target job
                            $thats_it=1;
                            $_="### by croint ### ".$_;
                        } elsif (!/^\#/ && $thats_it==1) {    #targrt job
                            $_="### by croint ### ".$_;
                            $thats_it=0;
                        } else {    #any other string
                            next;
                        }
                    } else {
                        1;
                        if (/^\#\{\s*name=$job_rules[0] /) {    #rules of target job
                            $thats_it=1;
                        } elsif (!/^\#/ && $thats_it==1) {    #targrt job
                            my @arr=split;
                            $arr[1]=$new_hours;
                            $_=join(' ',@arr);
                            $thats_it=0;
                        } else {
                            next;    #any other string
                        }
                    }
                }
            }

            ### SHIFT ###
            if (defined $job_rules[5]) {    #is shift defined?
                my @new_job_time;
                if ($job_rules[5] <0) {
                    @new_job_time=&add_delta_time($job_rules[5],@start_moment);
                    1;
                } elsif ($job_rules[5] >0) {
                    @new_job_time=&add_delta_time($job_rules[5],@end_moment);
                } else {
                    next;
                }
                my $new_rule_str;
                my $new_job_str;
                my $thats_it=0;
                foreach(@shiftout) {
                    next if /^$/;
                    chomp;
                    if (/^\#\{.*name=$job_rules[0] /) {
                        $thats_it=1;
                        $new_rule_str=$_;
                        $new_rule_str=~s/name=$job_rules[0]/name=$job_rules[0]_shifted/;
                    } elsif (!/^\#/ && $thats_it==1) {
                        my @arr=split;
                        $new_job_str=(join ' ', @new_job_time[4,3,2,1])." * ".$job_rules[15];
                        $thats_it=0;
                    } else {
                        next;
                    }
                }
                push @append,$new_rule_str;
                push @append,$new_job_str;
            }
        }
    }

    foreach (@skipout) {
        print CRONOUT "$_\n";
    }
    print CRONOUT "############################################\n";
    print CRONOUT "# THE FOLLOWING JOBS WHERE ADDED BY CRONIT #\n";
    print CRONOUT "############################################\n";
    foreach (@append) {
        print CRONOUT "$_\n";
    }
    close CRONOUT;
    print "\nCrontab file $file.out was generated\n"

########################### INFO begin ##############################

} elsif ($action eq "info") {
    open (CRONCSV,">$file.csv");
    print CRONCSV "Name,Description,Contact,Month,Days,Weekdays,Hours,Minutes,Command\n";
    foreach (@cron_rules) {
        my @arr=split(':',$_);
        foreach my $str (@arr[0,1,2,14,12,13,11,10,15]) {
            $str=~s/\,/\;/g;
            $str=~s/\|/ /g;
            print CRONCSV "$str,";
        }
        print CRONCSV "\n";
    }
    close CRONCSV;

########################### INFO end ##############################


} else {
    print "\nInvalid action $action\nProcess ABORTED!!!\n";
    exit 1;
}
print "\nProcess completed successfully\n";
exit 0;

#@cron_rules array
#name           0
#description    1
#contact        2
#duration       3
#skip           4
#shift          5
#before         6
#after          7
#not_with       8
#window         9
#min            10
#hours          11
#days           12
#weekdays       13
#months         14
#command        15

############################# SUBROUTINES #############################

sub get_job_times {
    my($timepart,$minval,$maxval)=@_;
    my @val;
    my @arr_out = ();
    my @arr=split(',',$timepart);
    foreach my $str (@arr) {
        if ($str=~/\-/ ) {
            @val = split ('-',$str);
            1;
            if ($val[0] < $val[1]) {
                for (my $i=$val[0];$i<=$val[1];$i++) {
                    push @arr_out,&two_digit($i);
                }
            } elsif ($val[0] > $val[1]) {
                for (my $i=$val[0];$i<=$maxval;$i++) {
                    push @arr_out,&two_digit($i);
                }
                for (my $i=$minval;$i<=$val[1];$i++) {
                        push @arr_out,&two_digit($i);
                }
            } else {
                push @arr_out,&two_digit($val[0]);
            }
        } elsif ($str eq '*') {
            for (my $i=$minval;$i<=$maxval;$i++) {
                push @arr_out,&two_digit($i);
            }
        } else {
            push @arr_out,&two_digit($str);
        }
    }
    @arr_out = sort {$a<=>$b} @arr_out;
    return @arr_out;
}


sub dow_is_ok {
    my ($year,$month,$day,$job_week_day_ref)=@_;
    my $dow = Day_of_Week($year,$month,$day);
    $dow =  0 if ($dow==7);
    my $is_ok = 0;
    foreach my $i (@{$job_week_day_ref}) {
        $is_ok++ if ($i==$dow);
    }
    return $is_ok;
}

sub two_digit {
    my ($x)=@_;
    $x = join('','0',$x) if (length($x) <2);
    return $x;
}

sub get_job_instances {
    my ($start_moment_ref,$end_moment_ref,$job_recur_ref) = @_;

    my $job_times;
    my @job_instances;
    my ($start_month_day,$end_month_day,$job_month_day);
    my (@job_month,@job_month_day,@job_week_day,@job_hour,@job_min);
    my (@job_month_scop,@job_month_day_scop,@job_week_day_scop,@job_hour_scop,@job_min_scop);
    my ($str_year,$str_month,$str_day,$str_hour,$str_min);
    my ($start_year,$start_month,$start_day,$start_hour,$start_min);
    my ($end_year,$end_month,$end_day,$end_hour,$end_min);

    #Arrays of job recurrencesdefinition
    @job_min = &get_job_times($$job_recur_ref[0],0,59);
    @job_hour = &get_job_times($$job_recur_ref[1],0,23);
    @job_month_day = &get_job_times($$job_recur_ref[2],0,31);
    @job_month = &get_job_times($$job_recur_ref[3],0,12);
    @job_week_day = &get_job_times($$job_recur_ref[4],0,6);

    #Arrays of time boundaries definition
    $start_year=$$start_moment_ref[0];
    $start_month=&two_digit($$start_moment_ref[1]);
    $start_month_day=&two_digit($$start_moment_ref[2]);
    $start_hour=&two_digit($$start_moment_ref[3]);
    $start_min=&two_digit($$start_moment_ref[4]);

    $end_year=$$end_moment_ref[0];
    $end_month=&two_digit($$end_moment_ref[1]);
    $end_month_day=&two_digit($$end_moment_ref[2]);
    $end_hour=&two_digit($$end_moment_ref[3]);
    $end_min=&two_digit($$end_moment_ref[4]);

    ### creating hash of jobs ###
    for ($str_year=$start_year;$str_year<=$end_year ;$str_year++) {
#       print "\n\$str_year:  $str_year   \$end_year: $end_year";
        @job_month_scop = grep (($_>=$start_month and $_<=$end_month),@job_month) if ($start_year==$end_year);
        @job_month_scop = grep (($_>=$start_month and $_<=12),@job_month) if ($str_year==$start_year and $str_year<$end_year);
        @job_month_scop = grep (($_>=1 and $_<=$end_month),@job_month) if ($str_year==$end_year and $str_year>$start_year);
#       print "\njob_month:    ",join (' ',@job_month);
        foreach my $str_month (@job_month_scop) {
            my $begin=join('',$start_year,$start_month);
            my $end=join('',$end_year,$end_month);
            my $str=join('',$str_year,$str_month);
            @job_month_day_scop = grep (($_>=$start_month_day and $_<=Days_in_Month($str_year,$str_month)
                        and &dow_is_ok($str_year,$str_month,$_,\@job_week_day)),@job_month_day) if ($str==$begin and $str<$end);
            @job_month_day_scop = grep (($_>=1 and $_<=Days_in_Month($str_year,$str_month)
                            and &dow_is_ok($str_year,$str_month,$_,\@job_week_day)),@job_month_day) if ($str>$begin and $str<$end);
            @job_month_day_scop = grep (($_>=1 and $_<=$end_month_day
                            and &dow_is_ok($str_year,$str_month,$_,\@job_week_day)),@job_month_day) if ($str >$begin and $str==$end);
            @job_month_day_scop = grep (($_>=$start_month_day and $_<=$end_month_day
                            and &dow_is_ok($str_year,$str_month,$_,\@job_week_day)),@job_month_day) if ($begin==$end);
#           print "\njob_month_day          ",join (' ',@job_month_day);
            foreach my $str_month_day (@job_month_day_scop) {
                my $begin=join('',$start_year,$start_month,$start_month_day);
                my $end=join('',$end_year,$end_month,$end_month_day);
                my $str=join('',$str_year,$str_month,$str_month_day);
                @job_hour_scop = grep (($_>=$start_hour and $_<=23),@job_hour) if ($str==$begin and $str<$end);
                @job_hour_scop = grep (($_>=0 and $_<=23),@job_hour) if ($str>$begin and $str<$end);
                @job_hour_scop = grep (($_>=0 and $_<=$end_hour),@job_hour) if ($str>$begin and $str==$end);
                @job_hour_scop = grep (($_>=$start_hour and $_<=$end_hour),@job_hour) if ($begin==$end);
#               print "\njob_hour                 ",join(' ' ,@job_hour);
                foreach my $str_hour (@job_hour_scop) {
                    my $begin=join('',$start_year,$start_month,$start_month_day,$start_hour); #pint "\n\$begin: $begin";
                    my $end=join('',$end_year,$end_month,$end_month_day,$end_hour); #print "\n\$end: $end";
                    my $str=join('',$str_year,$str_month,$str_month_day,$str_hour); #print "\n\$str: $str";
#                   print "\n\@job_min: ", join(' ',@job_min);
                    @job_min_scop = grep (($_>=$start_min and $_<=59),@job_min) if ($str==$begin and $str<$end);
                    @job_min_scop = grep (($_>=0 and $_<=59),@job_min) if ($str>$begin and $str<$end);
                    @job_min_scop = grep (($_>=0 and $_<=$end_min),@job_min) if ($str >$begin and $str==$end);
                    @job_min_scop = grep (($_>=$start_min and $_<=$end_min),@job_min) if ($begin==$end);
#                   print "\njob_min                             ",join(' ' ,@job_min);
                    foreach my $str_min (@job_min_scop) {
                        $job_times = join(':',$str_year,$str_month,$str_month_day,$str_hour,$str_min);
                        push @job_instances,$job_times;
#                       print "\n\$job_key=  ",$job_key, "           \$job_body=  ",$job_body;
                      } #str_min
                } #str_hour
            } #str_mday
        } #str_mon
    } #str_year
    return @job_instances;
}

sub print_help {
    print "\nUsage: cronit action [-t hh:mm[-hh:mm]] [-d dd/mm[-dd/mm]] [-s servername] [-u username] [-f filename]";
    print "\n       croninheet [-h]";
    print "\n          Action maybe: show, check, shift, info";
    print "\n          Notes:";
    print "\n       1) If no date is defined then the current day is displayed";
    print "\n       2) If beginning month number is more than the ending month number \n\t";
    print "  then the ending date is trated as the next year";
    print "\n       3) If end date isn't defined and the beginning time is more than the ending time \n\t";
    print "  then the ending date is treated as the next day";
    print "\n";
}

sub get_job_body {
    my $job_body = "@_";
    for (my $i=1;$i<=5 ; $i++) {
        $job_body =~s/^\s+//;
        $job_body =~s/\s+/ /;
        my $j=index($job_body,' ');
        $j++;
        $job_body = substr ($job_body,$j);
    }
    return $job_body;
}

sub add_delta_time {
    my ($delta,@job_instance)=@_;
    my $time=&Date_to_Time(@job_instance[0..4],0);
    $time=$time+$delta*60;
    my @x=((&Time_to_Date($time))[0..4]);
    return (map {two_digit($_)}(&Time_to_Date($time))[0..4]);
}

sub is_within {
    my ($start_moment_ref,$end_moment_ref,$event_moment_ref) = @_;
    my $start_time=&Date_to_Time((@$start_moment_ref[0..4]),0);
    my $end_time=&Date_to_Time((@$end_moment_ref[0..4]),0);
    my $event_time=&Date_to_Time((@$event_moment_ref[0..4]),0);
    if ($start_time <= $event_time and $event_time <= $end_time) {
        return 1;
    } else {
        return 0;
    }
}

sub get_proxy_interval {
    my @sched=@_;
    my @recur=(@sched[0,1],"*","*","*");
    my $eng_today=join (' ',(split(' ',localtime (time)))[1,2,4]);
    my @today=&Decode_Date_US($eng_today);
    my @start_time=(@today[0..2],00,00);
    my @end_time=(@today[0..2],23,59);
    my @instances=&get_job_instances(\@start_time,\@end_time,\@recur);
    my $proxy_interval=int(1440/(scalar @instances)/3);
    $proxy_interval=180 if $proxy_interval>180;
    return $proxy_interval;
}

sub get_sched_str {
    my @arr=@_;
    @arr=sort {$a<=>$b} @arr;
    my $out='';
    my @cont=();
    for (my $i=0;$i<=$#arr;$i++) {
        push (@cont,$arr[$i]);
        if ($i <$#arr && $cont[$#cont]+1==$arr[$i+1]) {
            next;
        }
        if (scalar @cont == 1) {
            $out="$out$cont[0]";
        } elsif (scalar @cont==2) {
            $out="$out$cont[0],$cont[1]";
        } else {
            $out="$out$cont[0]-$cont[$#cont]";
        }
        @cont=();
        if ($i!=$#arr) {
            $out="$out,";
        }
    }
    return $out;
}