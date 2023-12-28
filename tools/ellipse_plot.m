function ellipse_plot(center,covar,colorstr)
if (nargin<3)
    colorstr='r';
end
% inspired from libra
deter=covar(1,1)*covar(2,2)-covar(1,2)^2;
ylimit=sqrt(7.37776*covar(2,2));
y=-ylimit:0.005*ylimit:ylimit;
sqtdi=sqrt(deter*(ylimit^2-y.^2))/covar(2,2);
sqtdi([1,end])=0;
b=center(1)+covar(1,2)/covar(2,2)*y;
x1=b-sqtdi;
x2=b+sqtdi;
y=center(2)+y;
ellip=[x1,x2([end:-1:1]);y,y([end:-1:1])]';
line(ellip(:,1),ellip(:,2),'Color',colorstr); hold on
plot(center(1),center(2),'g+'); hold off