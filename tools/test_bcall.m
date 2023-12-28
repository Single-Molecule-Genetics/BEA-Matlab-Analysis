% Serie of tests

%% Test a normal use
clear;
directory='/home/jerome/work/data/irene/JKU/11-10-10 Multiplex 754 (1SNP)/';
options.cg='/SNP*'
bcall(directory, options);

%% Test a dye switch
clear;
directory='/home/jerome/work/data/irene/ACH 6-22 with dye switch/';
options.cg='ACH*';
dyeswitch_bcall(directory, options);

