function options=extract_non_garbage_image(pt,options)

d=dir([pt options.cg]);
n2x2=length(d);

if ~isfield(options,'image')
    options.image=-1;
end

e=preload([pt d(1).name]);
for i=2:n2x2
    e=combine_experiments(e,preload([pt d(i).name]));
end
e=extract_image(e,options.image);

% compute mean by image
k=1;
for i=1:max(e.image)
    idx=find(e.image==i);
    if ~isempty(idx)
        x(k,:) = mean(e.intensities(idx,:));
        y(k) = i;
        k=k+1;
    end
end
% remove image whose mean is different from the average
t=x>repmat(median(x)+2*rstd(x),size(x,1),1);
options.image=y(find(max(t,[],2)==0));
options.removed=y(find(max(t,[],2)==1));

if ~isempty(options.removed)
    disp(['Remove images : ' num2str(options.removed) ]);
end
