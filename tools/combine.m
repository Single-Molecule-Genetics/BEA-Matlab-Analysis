function e=combine(analyzedexp,options)
disp('combining')
%% combine
e=combine_experiments(analyzedexp(1),analyzedexp(2));

% converting ?? into 00
if ~isfield(options,'proba')
    options.proba=0;
end

if options.proba>0
    disp('converting ?? into 00')
        cc=0:max(e.code);
        ccstr=code2str(cc,length(e));
        ccstr(find(ccstr=='?'))='0';
        newcc=str2code(ccstr);
        for i=0:max(e.code);
            if (cc(i+1)~=newcc(i+1))
                e.code(find(e.code==i))=newcc(i+1);
            end
        end
end

h=hist(e.code,0:max(e.code));
%disp(['Counts for ' pt])
unclassified=0;
kunc=0;
for c=0:length(h)-1
    s=code2str(c,length(e));
    if isempty(strfind(s,'?'))       
        disp(sprintf('%2d %s: %7d',c,s,h(c+1)))
    else
        kunc=kunc+1;
        unclassified=unclassified+h(c+1);
    end
end
if length(h)>30
    disp('Result table too long, see summary.txt.')
end
disp(['Total unclassifed : ' num2str(unclassified)]);


