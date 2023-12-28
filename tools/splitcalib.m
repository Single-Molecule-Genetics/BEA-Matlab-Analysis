clear
%% Part 1
directory1 ='/home/jerome/work/data/irene/ACH 6-22 with dye switch/ACH 6-22';
directory2 ='/home/jerome/work/data/irene/ACH 6-22 with dye switch/ACH 6-22 ds';
options.cg='/ACH*';
options.beta=0.5;
options1 = calibration(directory1,options);
save([directory1, '\mycalib1.mat'],'options1');
%options.beta=0.8
options2 = calibration(directory2,options);
save([directory2, '\mycalib2.mat'],'options2');
%% Part 2

%%

%mycalib1 = load([directory1 '\mycalib1.mat']);
%mycalib2 = load([directory2 '\mycalib2.mat']);
mycalib1 = load('/home/leila/Images/Irene/mycalib1.mat']);
mycalib2 = load('/home/leila/Images/Irene/mycalib2.mat']);
directory3 ='Z:\Analysis\ACH Project\ACH scan Piece 01-01 to 01-06 date 04-10-11\ACH piece 01-02 ds\ACH 1-02';%uigetdir
directory4 ='Z:\Analysis\ACH Project\ACH scan Piece 01-01 to 01-06 date 04-10-11\ACH piece 01-02 ds\ACH 1-02 ds';
directory5 ='Z:\Analysis\ACH Project\ACH scan Piece 01-01 to 01-06 date 04-10-11\ACH piece 01-02 ds';
clear e
e(1)=apply(directory3,mycalib1.options1);
e(2)=apply(directory4,mycalib2.options2);

e=combine(e,options);
save_combined_experiment(e,mycalib2.options2,directory5);