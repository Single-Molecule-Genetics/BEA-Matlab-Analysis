
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pt is supposed to contain BF, Red, GFP images (diff. positions and times)
% threshOffset - ignores images with alignment offsets bigger than threshOffset
% saveIm = 1, saves all aligned images an the masks (in the result directory)
% Output: experiment.mat files in output directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AnalyzeBeads(pt, threshOffset, mapFile, resDir, saveIm);
AnalyzeBeads('Z:\something\directory to analyze', 500, 'MapFile.ini', 'Z:\something\Resultdirectory', 0);
AnalyzeBeads('Z:\something\directory to analyze', 500, 'MapFile.ini', 'Z:\something\Resultdirectory', 0);
%repeat as many times as needed
