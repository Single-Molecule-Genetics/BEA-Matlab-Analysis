function corr_offset = Register2Im(A, B)
% x,y means that A can be found in B if translated in first dim with x and
% in second with y

% template = .2*ones(11); % Make light gray plus on dark gray background
% template(6,3:9) = .6;   
% template(3:9,6) = .6;
% BW = template > 0.5;      % Make white plus on black background
% figure, imshow(BW), figure, imshow(template)
% % Make new image that offsets the template
% offsetTemplate = .2*ones(21); 
% offset = [3 5];  % Shift by 3 rows, 5 columns
% offsetTemplate( (1:size(template,1))+offset(1),...
%                 (1:size(template,2))+offset(2) ) = template;
% figure, imshow(offsetTemplate)
    
% Cross-correlate A and B to recover offset 
if max(max(A)) ~= min(min(A)) & max(max(B)) ~= min(min(B))
    cc = normxcorr2(A,B); 

    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [ (ypeak-size(A,1)) (xpeak-size(A,2)) ]
else
    corr_offset = [ 500 500 ];
end
% figure;
% imagesc(cc)
%isequal(corr_offset,offset) % 1 means offset was recovered
