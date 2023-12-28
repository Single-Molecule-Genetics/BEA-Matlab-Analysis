%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LM , June 2013
% Registers all the images in the directory structure
% Segment the BF images
% Find spots in the fluorescent images and position them inside the meshes
% obtained from BF
% pt is supposed to contain BF, Red, GFP images (diff. positions and times)
% threshOffset - ignores images with alignment offsets bigger than threshOffset
% saveIm = 1, saves all aligned images an the masks (in the result directory)
% Output: experiment.mat files in output directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AnalyzeBeads(pt, threshOffset, mapFile, resDir, saveIm)
%%

sep = '/';
if ~exist('pt')
    pt = uigetdir 
    pt = strcat(pt,sep);
    if pt == 0
       disp ('No directory selected') 
       return; 
    end
end
if ~exist('resDir')
    resDir = uigetdir(pt, 'Select result directory') 
    resDir = strcat(resDir,sep);
    if pt == 0
       disp ('No directory selected') 
       return; 
    end
end
if ~exist('mapFile')
    mapFile = strcat(resDir,'MapFile.ini')
end
if ~exist('threshOffset')
    threshOffset = 500;
end

if ~exist('saveIm')
    saveIm = 1;
end
drs = dir(pt);
savef = 1;


%% Create mask. Register brightfield and find common beads
imageon = 0;
fid = fopen(mapFile, 'w');
fprintf(fid,'%s \n', '[Matlab]');

dName = dir(pt);
auxDir = [dName.isdir];
idxDir = find(auxDir>0);

if ~strcmp(pt(end), sep) pt = strcat(pt,sep);  end;
fls = dir(strcat(pt, drs(idxDir(3)).name, sep, '*.tif'));
if isempty(fls) fls = dir(strcat(pt, drs(idxDir(3)).name, sep, '*.TIF')); end

if savef
for k = 3:length(idxDir)
    mkdir(strcat(resDir,drs(idxDir(k)).name));
    delete(strcat(resDir, drs(idxDir(k)).name, sep, '*.log'));
end
end

if length(fls)>0
    for k = 1:size(fls,1)
        disp(strcat('Im. no. ',num2str(k)));
        name = strcat(pt,drs(idxDir(3)).name, sep, fls(k).name);     
        nr = regexp( fls(k).name, '\d+', 'match');
%         if nr{1} == '1'
%             ofs = -1;
%         else
%             ofs = 0;
%         end
        
        % Align brightfield (grayscales or masks?), compute mask. Identifier of a bead - identifier in first image. 
        % First image has all detected beads. Subsequent images - only the
        % beads overlapping with first image (from which they borrow the
        % identifier)
        
        if ~isempty(findstr(name, 'w1')) & (length(nr)>2)
            A = double(imread(name));
            [m mask] = BeadSegWav(A);
            Lab = bwlabel(mask);
            if saveIm
               imwrite(uint16(Lab), strcat(resDir,drs(idxDir(3)).name, sep,'Mask_s',nr{3},'.tif'), 'tif', 'Compression', 'None');
            end
            rp  = regionprops(mask, A, 'Area', 'MeanIntensity');
            %[Denoised m Backgr noiseStd wave] = FindPeakWav(-A, 0.05, 0, 4, 1, -1);
            dNo = str2num(nr{1})
            sNo = str2num(nr{3});
            
            % Save fluorescence data
            fluorfiles = dir(strcat(pt, drs(idxDir(3)).name, sep, strcat('*_w*_s', nr{3}, '_*')));           
            
            for kf = 2:length(fluorfiles)
                nrf = regexp( fluorfiles(kf).name, '\d+', 'match');
                if nrf{2}>1
                    name = strcat(pt,drs(idxDir(3)).name, sep, fluorfiles(kf).name);
                    try
                        B = double(imread(name));   
                    catch
                        disp(strcat('Could not open ', name)); 
                        break; 
                    end
                    rpF  = regionprops(Lab, B, 'Area', 'MeanIntensity');
                    a = [rpF.Area];
                    mi = [rpF.MeanIntensity];
                    res = [str2num(nrf{1})*ones(max(Lab(:)),1) str2num(nrf{3})*ones(max(Lab(:)),1) (1:max(Lab(:)))' a' mi' ];
                % Save in the file corresponding to nrf{2}
                    
                    logfile = strcat(resDir,drs(idxDir(3)).name, sep,'w',nrf{2},'.log');
                    if (~exist(logfile,'file'))
                        dlmwrite(logfile, res);
                    else
                        dlmwrite(logfile, res, '-append');
                    end
                end
            end
%             experiment=load_mm_simple(strcat(resDir,drs(idxDir(3)).name, sep));
%             save(strcat(resDir,drs(idxDir(3)).name, sep,'experiment.mat'),'experiment');
            
            fprintf(fid,'x_%d_%d=%d\n', dNo, sNo, 0);
            fprintf(fid,'y_%d_%d=%d\n', dNo, sNo, 0);
            reg = [dNo, sNo, 0, 0];
            for q = 4:length(idxDir) 
                if drs(q).isdir   
                    % BF mask analysis
                    % ff = dir(strcat(pt, drs(idxDir(q)).name, sep, strcat('*',nr{1},'_w1_s', nr{3}, '_*')));
                    % For some reasons some 1-s and 0s added/removed at the beginning of dNo
                    ff = dir(strcat(pt, drs(idxDir(q)).name, sep, strcat('*_w1_s', nr{3}, '_*')));
                    if length(ff)~=1             
                        disp(strcat('Could not find file or not unique:', strcat('*',nr{1},'_w1_s', nr{3}, '_*'))); 
                        break; 
                    else
                    name = strcat(pt,drs(idxDir(q)).name, sep, ff(1).name);
                    try
                        B = double(imread(name));   
                    catch
                        disp(strcat('Could not open ', name)); 
                        break; 
                    end
                    if imageon
                        figure
                        subplot 121
                        imagesc(A); axis equal tight; colormap gray; title(num2str(k)) 
                        subplot 122
                        imagesc(B); axis equal tight; colormap gray; title(name)
                    end
                    
                    u(1) = min(1400, min(size(A,1), size(B,1)));
                    u(2) = min(1400, min(size(A,2), size(B,2)));
                    x = Register2Im( A(400:u(1), 400:u(2)), B(400:u(1), 400:u(2)));
                    
                    reg = [reg; dNo sNo x(1) x(2)]
                    [m2 mask2] = BeadSegWav(B);  
                    %xx = Register2Im( mask(400:u(1), 400:u(2)), mask2(400:u(1), 400:u(2)));
                    %xx-1
                    %[Denoised m2 Backgr noiseStd wave] = FindPeakWav(-B, 0.05, 0, 4, 1, -1);
                    x = x-1;            
                    
                    if abs(x)<threshOffset 
                    
                    % align to first BF 
                    m2 = Align(m2, [x(1) x(2)]);
                    mask2 =  Align(mask2, [x(1) x(2)]);
                    
                    % make the correspondance between label for A and label
                    % for B                    
                    Lab2  = bwlabel(mask2);
                    LabInters = bwlabel(mask&mask2);
                    rpInters  = regionprops(LabInters, Lab, 'Area', 'MaxIntensity');
                    rpInters2  = regionprops(LabInters, Lab2, 'Area', 'MaxIntensity');
                    
                    % In pairing for the overlapping beads: Area of intersection, Id in A, Id in B,
                    pairing = [[rpInters.Area]' [rpInters.MaxIntensity]' [rpInters2.MaxIntensity]'];
                    
                    if ~isempty(pairing)
                    pairing = sortrows(pairing,[2 -1 3]);
                    
                    % Clean of duplicates
                    % Find first appearance for each bead in B and keep it (ordered according to decreasing area!)         
                    %id = 1:size(pairing,1);
                    [v id1] = unique(pairing(:,2), 'first');
                    pairing = pairing(id1, :);
                    %id = id(id1);
                    pairing = sortrows(pairing,[3 -1 2]);
                     % Find first appearance for each bead in A                   
                    [v id2] = unique(pairing(:,3), 'first');
                    pairing = pairing(id2, :);
                    %id = id(id2);
                    % Fluorescence intensity analysis
                    
                    fluorfiles = dir(strcat(pt, drs(idxDir(q)).name, sep, strcat('*_w*_s', nr{3}, '_*')));                   
                    nrf = regexp( fluorfiles(1).name, '\d+', 'match');
                    dNo = str2num(nrf{1});
                    if saveIm
                        Lab3 = zeros(size(Lab2));
                        for kk = 1:size(pairing,1)
                            Lab3(Lab2==pairing(kk,3)) = pairing(kk,2);
                        end
                        imwrite(uint16(Lab3), strcat(resDir,drs(idxDir(q)).name, sep,'Mask_s',nrf{3},'.tif'), 'tif', 'Compression', 'None');
                    end
                    for kf = 2:length(fluorfiles)
                        nrf = regexp( fluorfiles(kf).name, '\d+', 'match');
                        
                        if nrf{2}>1
                            name = strcat(pt,drs(idxDir(q)).name, sep, fluorfiles(kf).name);
                            try
                                B = double(imread(name));   
                            catch
                                disp(strcat('Could not open ', name)); 
                                break; 
                            end
                            B2 =  Align(B, [x(1) x(2)]);
                            rpF  = regionprops(Lab2, B2, 'Area', 'MeanIntensity');
                            a = [rpF.Area];
                            mi = [rpF.MeanIntensity];                            
                            res = [str2num(nrf{1})*ones(size(pairing,1),1) str2num(nrf{3})*ones(size(pairing,1),1) pairing(:,2) a(pairing(:,3))' mi(pairing(:,3))' ];
                        % Save in the file corresponding to nrf{2}
                            if saveIm
                                imwrite(uint16(B2), strcat(resDir,drs(idxDir(q)).name, sep,'Alignw',nrf{2},'s',nrf{3},'.tif'), 'tif', 'Compression', 'None');
                            end
                            logfile = strcat(resDir,drs(idxDir(q)).name, sep,'w',nrf{2},'.log');
                            if savef
                                
                            if (~exist(logfile,'file'))
                                dlmwrite(logfile, res);
                            else
                                dlmwrite(logfile, res, '-append');
                            end
                            end
                        end
                    end
                    
                    
%                     experiment=load_mm_simple(strcat(resDir,drs(idxDir(q)).name, sep));
%                     save(strcat(resDir,drs(idxDir(q)).name, sep,'experiment.mat'),'experiment');
                    
                    % fluorfiles(kf).name
                    fprintf(fid,'x_%d_%d=%d\n', dNo, sNo, x(2));
                    fprintf(fid,'y_%d_%d=%d\n', dNo, sNo, x(1));
                    if imageon
                        rgb(:,:,1) = m;
                        rgb(:,:,2) = m2;
                        rgb(:,:,3) = zeros(size(mask));
                        figure; imagesc(rgb)
                       % ylim([1420 1520]); xlim([1 120])
                        rgb(:,:,1) = mask;
                        rgb(:,:,2) = mask2;
                        rgb(:,:,3) = zeros(size(mask));
                        figure; imagesc(rgb)
                        %ylim([1420 1520]); xlim([1 120])
                        rgb2(:,:,1) = double(A)/max(A(:));
                        rgb2(:,:,2) = Align(double(B),x);
                        rgb2(:,:,2) = double(rgb2(:,:,2))/max(max(rgb2(:,:,2)));
                        rgb2(:,:,3) = zeros(size(mask));
                        figure; imagesc(rgb2)
                        %ylim([1420 1520]); xlim([1 120])
                        %VisColor(A, Align(B,x));
                        mask = mask & mask2;
                        figure; imagesc(mask);
                        % save mask2?
                        pause
                    end
                    end
                    end
                    end
                end
            end

        end
    end
end
fclose(fid)
%CheckShifts(strcat(pt, 'MapFile.ini'));
CheckShifts(mapFile);


