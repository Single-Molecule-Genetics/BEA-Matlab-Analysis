function [mask mask2] = BeadSegWav(Im)


%% Wavelet detection
[Denoised Res Backgr noiseStd wave] = FindPeakWav(-Im, 0.05, 0, 4, 1, -1);
nmask = imfill(Res, 'holes');  
mask = nmask>Res;
% watershed with seeds - the detected centers?
%%

%nmask =imerode(~nmask, strel('disk',2));
nmask = imerode(nmask, strel('disk',1));
%figure; imshow(nmask,[]); title('frame')

%mask2 = imclose(mask, strel('disk',1));
%mask2 = bwmorph(mask2, 'thin', Inf);
mask = bwmorph(mask.*nmask, 'thicken', 1);
%figure; imshow(mask,[])
%mask2 = bwmorph(mask.*nmask, 'thicken', 3); %-ceil(sqrt(medArea))) ;

%mask2 = mask.*nmask;
%figure; imshow(mask2-nmask,[]); title('final mask')
%%
rp  = regionprops(mask, 'Area', 'Eccentricity');
%areas = cat(1, rp.Area);
[L,n] = bwlabel(mask);
medArea = median([rp.Area]);
rA = [rp.Area]; rA(rA>500) = [];
madArea = mad(rA)
idx = find(([rp.Area] <medArea+3*madArea) & ([rp.Eccentricity]<0.8));
mask2 = ismember(L,idx);