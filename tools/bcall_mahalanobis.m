function d=bcall_mahalanobis(X,m,C)
%
% d=bcall_mahalanobis(X,m,C)
%
% Compute Mahalanobis distance
% X : n vectors [n,m]
% m : mean [1,m]
% C : covariance matrix [m,m]
%

if cond(C)>1e6
   [U,S,V] = svd(C);
   S=max(S,S(1)*1e-2);
   C=U*S*V';
end

if rcond(C)<1e-6
   [U,S,V] = svd(C);
   S=max(S,S(1)*1e-2);
   C=U*S*V';
end

%size(m)
%size(C)
%size(X)

iC=inv(C);
dx = X-ones(size(X,1),1)*m;
dxc = dx*iC;
d = dot(dx,dxc,2);
