% method ultra-heuristique
clf
x=log2(experiment.intensities(:,1));
y=log2(experiment.intensities(:,2));

if 0
x=ones(10,1)*linspace(-5,5,11);
y=linspace(-5,5,10)'*ones(1,11);
x=x(:);
y=y(:);
end

A = (x+y)/2;
M = x-y;

lambda=8;

sx=lambda*rstd(x,1);
sy=lambda*rstd(y,1);
sm=lambda*rstd(M,1);
sa=lambda*rstd(A,1);

plot(A,M,'+');
hold on
t=-20:.1:20;
plot(t,2*t,'r')
plot(t+sy/2,2*t-sy,'r--')
plot(t-sy/2,2*t+sy,'r--')

plot(t,-2*t,'g')
plot(t-sx/2,-2*t-sx,'g--')
plot(t+sx/2,-2*t+sx,'g--')

plot(t,t-t,'m')
plot(t,(t./t)*sm,'m--')
plot(t,-(t./t)*sm,'m--')

plot(t-t,t,'m')
plot((t./t)*sa,t,'m--')
plot(-(t./t)*sa,t,'m--')

idx=find(y<sy & (M>sm |x>sx));
plot(A(idx),M(idx),'r+')

idx=find(x<sx & (M<-sm | y>sy));
plot(A(idx),M(idx),'g+')

idx=find(y>sy & x>sx & A>sa);
plot(A(idx),M(idx),'m+')


xlabel('a')
ylabel('m')


axis square
hold off
