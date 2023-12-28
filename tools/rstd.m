function [s m]=rstd(data,type)
%
%  [std mean]=rstd(data,type)
%
%  Compute a robust standard deviation
%
%  type=0 : same as std()
%  type=1 : uses MAD
%  type=2 : uses LTS

if nargin<2
    type=1;
end

switch type
    case 0
        m = mean(data);
        s=std(data);
    case 1
        m = median(data);
        data = data-ones(size(data,1),1)*m; 
        s  = median(abs(data))/.6745;
    case 2        
        breakdown_pt = .5; % 50%  
        m = median(data);
        data = data-ones(size(data,1),1)*m; 
        sdata = sort(data.^2,1);
        s = sqrt(mean(sdata(1:round(size(data,1)*breakdown_pt),:))/0.143);
    case 3
        breakdown_pt = .25; % 25%
        m = median(data);
        data = data-ones(size(data,1),1)*m; 
        sdata = sort(data.^2,1);
        s = sqrt(mean(sdata(1:round(size(data,1)*breakdown_pt),:)))/0.1824;
    case 4
        breakdown_pt = .1; % 10%
        m = median(data);
        data = data-ones(size(data,1),1)*m; 
        sdata = sort(data.^2,1);
        s = sqrt(mean(sdata(1:round(size(data,1)*breakdown_pt),:)))/0.0725;
    otherwise
        error('rstd(data,type) : Unknown type');
end