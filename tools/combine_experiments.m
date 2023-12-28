function e3=combine_experiments(e1,e2)
%
% e3=combine_experiments(e1,e2)
%
% Combines two experiments
%
is_compatible = false;
if (e1.n == e2.n)    
    if (min(e1.object == e2.object) && min(e1.image == e2.image))
        is_compatible = true;
    end
end

if ~is_compatible
    disp('combine_experiments : data have not the same size.. try to compute an intersection');
    %[idx1 idx2] = intersect(e1, e2);
    [c, idx1, idx2] = intersect([e1.image e1.object] , [e2.image e2.object], 'rows');
    e3.image = e1.image(idx1);
    e3.object = e1.object(idx1);
    e3.intensities = [e1.intensities(idx1, :) e2.intensities(idx2,:)];
    if isfield(e1,'no_norm') && isfield(e2,'no_norm')
        e3.no_norm=[e1.no_norm(idx1,:) e2.no_norm(idx2,:)];
    end
    e3.nchannels = e1.nchannels + e2.nchannels;
    %e3.n=e1.n; % modify
    e3.n = size(c,1); 
    jcode=5.^(size(e1.intensities,2)/2);
    if isfield(e1,'code') && isfield(e2,'code')
        e3.code = e1.code(idx1) + jcode * e2.code(idx2);
    end
else
    e3.image = e1.image;
    e3.object = e1.object;
    e3.intensities = [e1.intensities e2.intensities];
    if isfield(e1,'no_norm') && isfield(e2,'no_norm')
        e3.no_norm=[e1.no_norm e2.no_norm];
    end
    e3.nchannels = e1.nchannels + e2.nchannels;
    e3.n=e1.n;
    jcode=5.^(size(e1.intensities,2)/2);
    if isfield(e1,'code') && isfield(e2,'code')
        e3.code = e1.code + jcode * e2.code;
    end
end



% function [idx1, idx2] = intersect(e1,e2)
% N = min(e1.n, e2.n);
% idx1 = ones(1, N);
% idx2 = ones(1, N);
% k = 0;
% nNotFound = 0;
% for i = 1:e1.n
%     found = false;
%     for j = 1:e2.n
%         if (e1.object(i) == e2.object(j) && e1.image(i) == e2.image(j))
%             k = k + 1;
%             idx1(k) = j;
%             idx2(k) = i;
%             found = true;
%         end        
%     end
%     if (~found)
%         fprintf(1,'%d (obj %d, img %d) not found\n',i,e1.object(i),e1.image(i));
%         nNotFound = nNotFound + 1;
%     end
% end
% fprintf(1, '%d not matching\n',nNotFound);
% idx1 = idx1(1:N);
% idx2 = idx2(1:N);
