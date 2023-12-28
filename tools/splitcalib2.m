clear
%% Part 1
directory1 ='/home/leila/Images/Irene/1264/ach 1264 with ds (images)/ACH 1264 ds';
directory2 ='/home/leila/Images/Irene/1264/ach 1264 with ds (images)/ACH 1264'
%options.cg='/ACH*';
options.cg='/11264*';
options.beta=0.5;
options1 = calibration(directory1,options);
save([directory1, '\mycalib1.mat'],'options1');
%options.beta=0.8
options2 = calibration(directory2,options);
save([directory2, '\mycalib2.mat'],'options2');
%% Part 2
%mycalib1 = load([directory1 '\mycalib1.mat']);
%mycalib2 = load([directory2 '\mycalib2.mat']);
mycalib1 = load('/home/leila/Images/Irene/mycalib1.mat');
mycalib2 = load('/home/leila/Images/Irene/mycalib2.mat');
%%
directory3 ='/home/leila/Images/Irene/1264/ach 1264 with ds (images)/ACH 1264';%uigetdir
directory4 ='/home/leila/Images/Irene/1264/ach 1264 with ds (images)/ACH 1264 ds';
directory5 ='/home/leila/Images/Irene/1264/ach 1264 with ds (images)';
clear e
mycalib1.options1 = '/ACH*'
mycalib2.options2 = '/ACH*'
e(1)=apply(directory3,mycalib1.options1);
e(2)=apply(directory4,mycalib2.options2);

e=combine(e,options);
save_combined_experiment(e,mycalib2.options2,directory5);