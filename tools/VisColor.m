function rgb1 = VisColor(img1, img2)

%addpath 'E:\leila\psf\Angela\'

if nargin < 1
%    img1 = double(imread('D:\leila\Images\0807MA\Sl2scan1_oli_sl757_514nm10.pgm'));
%    img2 = double(imread('D:\leila\Images\0807MA\scan1_sl757_647nm_1.pgm'));
    img2 = double(imread('G:\Side_popu_sl2\514nm\scan1_sl757_514nmnew.pgm'));
    img1 = double(imread('G:\Side_popu_sl2\647nm\scan1_sl757_647nm_103p2.pgm'));
end

clear rgb
% 
% [D1 R1 B1] =  ATrousDet1(img1, 1, 0, 4, 0);
% [D2 R2 B2] =  ATrousDet1(img2, 1, 0, 4, 0);
% 
% img1 = D1;
%img2 = D2;
sz = max( [size(img1); size(img2) ]);
img2 = double(padarray(img2, [max(0, sz(1) - size(img2,1)),   max(0, sz(2) - size(img2,2))] , 0, 'pre'));
img1 = double(padarray(img1, [max(0, sz(1) - size(img1,1)),   max(0, sz(2) - size(img1,2))] , 0, 'pre'));

% figure; imagesc((img2));

%img2 = img2/max(max(img2))*mean2(img1);

img1 = imadjust(uint8((img1-min(min(img1)))/( max(max(img1))- min(min(img1)))*255 ));
img2 = imadjust(uint8((img2-min(min(img2)))/( max(max(img2))- min(min(img2)))*255 ));

% img1 = (uint8((img1-min(min(img1)))/( max(max(img1))- min(min(img1)))*255 ));
% img2 = (uint8((img2-min(min(img2)))/( max(max(img2))- min(min(img2)))*255 ));


rgb(:, :, 2) = img1;
rgb(:, :, 1) = img2;
rgb(:, :, 3) = zeros(sz);

% 
% figure;
% hist(double(img2(:)), 200); title('Red')
% 
% 
% figure;
% hist(double(img1(:)), 200) ; title('Oli')

% rgb(:,:,1) =  rgb(:,:,1)/max(max(rgb(:,:,1)));
% rgb(:,:,2) = rgb(:,:,2)/max(max(rgb(:,:,2)));

rgb1 = rgb;

%rgb1 = imadjust(rgb,[0.0  0.0 0 ; 0.02  0.0001 1], []); % 0 0; 0.1 0.4 0.1],[]);
%rgb1 = imadjust(rgb,[0  0 0 ; 1  1 1], []); % 0 0; 0.1 0.4 0.1],[]);

figure;imagesc(rgb1); 
axis equal; axis tight;

%imwrite(rgb1,'E:\leila\Images\AngelaNoi\WOrigGreenShrinkRed', 'jpg')