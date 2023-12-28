function m1=force(m1,m0,data,options)
%c=.8; % how strong is the constraint
switch 3 % select type of constraint
    case 0 % keep m1 close to m0
        s=0;
        for i=1:length(m0.cluster)
            s=s+m0.cluster(i).n;
        end
        for i=1:length(m0.cluster)
            x=m0.cluster(i).n/s;
            c=exp(-.5*x);% how strong is the constraint
            m1.cluster(i).mean = c*m0.cluster(i).mean+(1-c)*m1.cluster(i).mean;
            m1.cluster(i).cov = c*m0.cluster(i).cov+(1-c)*m1.cluster(i).cov;
        end
    case 1 % keep distances between clusters and a central point
        C1=zeros(1,2);
        C0=C1;
        s=0;
        for i=1:length(m0.cluster)
            C1=C1+mean(m1.cluster(i).mean);
            C0=C0+mean(m0.cluster(i).mean);
            s=s+m0.cluster(i).n;
        end
        C1=C1/length(m1.cluster);
        C0=C0/length(m0.cluster);
        for i=1:length(m0.cluster)
            x=m0.cluster(i).n/s;
            c=exp(-.5*x);% how strong is the constraint
            d0 = m0.cluster(i).mean-C0;
            d1 = m1.cluster(i).mean-C1;
            d1 = d1/norm(d1)*norm(d0);
            m1.cluster(i).mean = c*(d1+C1)+(1-c)*m1.cluster(i).mean;
        end
    case 2 % orientation and deviation from the axe                
        kappa=options.max_cluster_size;
        
        m1.cluster(1).cov=condcov(m1.cluster(1).cov,[0.5 1.5]);
        
        c=sqrt(abs(det(m1.cluster(1).cov)));
        if (m1.cluster(3).flag~=1 && m1.cluster(2).flag~=1)
            d=.5*(sqrt(abs(det(m1.cluster(1).cov)))+sqrt(abs(det(m1.cluster(1).cov))));
            m1.cluster(2).cov=condcov(m1.cluster(2).cov,[d d]);
            m1.cluster(3).cov=condcov(m1.cluster(3).cov,[d d]);
            m1.cluster(4).cov=condcov(m1.cluster(4).cov,[d 2*d]);
        end
        m1.cluster(2).cov=condcov(m1.cluster(2).cov,[.01,kappa*c]);
        m1.cluster(3).cov=condcov(m1.cluster(3).cov,[.01,kappa*c]);
        if 0
            imax=max(data);
            ideal = .5*imax(1) + .5*m1.cluster(1).mean(1);
            m1.cluster(2).mean(1) = .5*(ideal + m1.cluster(2).mean(1));
            ideal = .5*imax(2) + .5*m1.cluster(3).mean(2);
            m1.cluster(3).mean(2) = .5*(ideal + m1.cluster(3).mean(2));
        end
        if m1.k>4
            % Maximal size of the satellites
            m1.cluster(5).cov=condcov(m1.cluster(5).cov,[.01 kappa*c/2]);
            m1.cluster(6).cov=condcov(m1.cluster(6).cov,[.01 kappa*c/2]);
            % keep the satellite shape in the axis (round)
            %m1.cluster(5).cov(1,2)=.9*m1.cluster(5).cov(1,2);
            %m1.cluster(5).cov(2,1)=.9*m1.cluster(5).cov(1,2);
            %m1.cluster(6).cov(1,2)=.9*m1.cluster(6).cov(1,2);
            %m1.cluster(6).cov(2,1)=.9*m1.cluster(6).cov(1,2);
            % keep the satellite close to cluster 1
            m1.cluster(5).mean(2) = .5*m1.cluster(5).mean(2)+.5*m1.cluster(1).mean(2);
            m1.cluster(5).mean(1) = .75*m1.cluster(5).mean(1)+.25*m1.cluster(1).mean(1);
            m1.cluster(6).mean(1) = .5*m1.cluster(6).mean(1)+.5*m1.cluster(1).mean(1);
            m1.cluster(6).mean(2) = .75*m1.cluster(6).mean(2)+.25*m1.cluster(1).mean(2);
        end
        if options.normalization_type~=5;
            % orientation of 2 and 3
            [u d v]=svd(m1.cluster(2).cov);
            dxi=u(1,1);
            dyi=u(2,1);
            if abs(dxi)>1e-9
                a2=atan(dyi/dxi);
                %disp(sprintf('orientation 2 %.2f deg',a/pi*180));
                if (a2<0)
                    %disp('hop 2')
                    a=-2*a2;
                    R=[cos(a) -sin(a);sin(a) cos(a)];
                    m1.cluster(2).cov=R*m1.cluster(2).cov*R';
                end
            end
            [u d v]=svd(m1.cluster(3).cov);
            dxi=u(1,1);
            dyi=u(2,1);
            if abs(dyi)>1e-9
                a3=atan(dxi/dyi);
                %disp(sprintf('orientation 3 %.2f deg',a/pi*180));
                if (a3<0)
                    %disp('hop 3')
                    a=2*a3;
                    R=[cos(a) -sin(a);sin(a) cos(a)];
                    m1.cluster(3).cov=R*m1.cluster(3).cov*R';
                end
            end
            % cluster 4 defined by 2 and 3
            %m1.cluster(4).cov=.9*(.5*m1.cluster(4).cov+.5*.5*(m1.cluster(2).cov+m1.cluster(3).cov));
            m1.cluster(4).cov=condcov(m1.cluster(4).cov,[0.01,kappa*c]);
            if m1.cluster(2).flag==0 ||  m1.cluster(3).flag==0
                ideal = [m1.cluster(2).mean(1) m1.cluster(3).mean(2)];
            else
                ideal = [m1.cluster(2).mean(1) m1.cluster(3).mean(2)]*.5 + (m1.cluster(2).mean + m1.cluster(3).mean)*.5*.5;
            end
            %m1.cluster(4).mean=.5*m1.cluster(4).mean+.5*ideal;
            %xa = .5*(m1.cluster(2).mean(1)+1.25*m1.cluster(4).mean(1));
            %ya = .5*(m1.cluster(3).mean(2)+1.25*m1.cluster(4).mean(2));
            %m1.cluster(2).mean(1)=.25*xa+.75*m1.cluster(2).mean(1);
            %m1.cluster(3).mean(2)=.25*ya+.75*m1.cluster(3).mean(2);
            %m1.cluster(4).mean=.25*(.75*[xa ya])+.75*m1.cluster(4).mean;
        else
            [u d v]=svd(m1.cluster(2).cov);
            dxi=u(1,1);
            dyi=u(2,1);
            if abs(dxi)>1e-9
                a2=atan(dyi/dxi);
                %disp(sprintf('orientation 2 %.2f deg',a/pi*180));
                if (a2<0)
                    %disp('hop 2')
                    a=-2*a2;
                    R=[cos(a) -sin(a);sin(a) cos(a)];
                    m1.cluster(2).cov=R*m1.cluster(2).cov*R';
                end
            end
            [u d v]=svd(m1.cluster(3).cov);
            dxi=u(1,1);
            dyi=u(2,1);
            if abs(dyi)>1e-9
                a3=atan(dxi/dyi);
                %disp(sprintf('orientation 3 %.2f deg',a/pi*180));
                if (a3<0)
                    %disp('hop 3')
                    a=-2*a3;
                    R=[cos(a) -sin(a);sin(a) cos(a)];
                    m1.cluster(3).cov=R*m1.cluster(3).cov*R';
                end
            end
            m1.cluster(4).cov=condcov(m1.cluster(4).cov,[0.01,kappa*c]);
        end
    case 3  
        beta=[options.beta options.beta*.1 options.beta]; % lower is stronger constraint
        
        if options.normalization_type~=5
                        
            % cluster 1, 2 and 3,4 have the same size and symetric position
            if (m1.cluster(3).flag==1 && m1.cluster(2).flag==1)
                d=(csz(m1.cluster(1).cov)+csz(m1.cluster(2).cov)+csz(m1.cluster(3).cov)+csz(m1.cluster(4).cov))/4;
                for i=1:4
                    c = m1.cluster(i).cov/sqrt(abs(det(m1.cluster(i).cov)))*d;
                    if i==4
                        %m1.cluster(i).cov=beta(1)*m1.cluster(i).cov+(1-beta(1))*c*1.5;
                    else
                        m1.cluster(i).cov=beta(1)*m1.cluster(i).cov+(1-beta(1))*c;
                    end
                end
            end
            
            %mx = .5*(m1.cluster(2).mean(1)+m1.cluster(3).mean(2));
            %m1.cluster(2).mean = beta(1)*m1.cluster(2).mean+(1-beta(1))*[mx m1.cluster(2).mean(2)];
            %m1.cluster(3).mean = beta(1)*m1.cluster(3).mean+(1-beta(1))*[m1.cluster(3).mean(1) mx];
            
            % Cluster 5 and 6 have the same size and are symmetric
            if length(m1.cluster)>5
                mx = (.5*(m1.cluster(5).mean(1)+m1.cluster(6).mean(2)));
                m1.cluster(5).mean = beta(2)*m1.cluster(5).mean+(1-beta(2))*[mx m1.cluster(1).mean(2)];
                m1.cluster(6).mean = beta(2)*m1.cluster(6).mean+(1-beta(2))*[m1.cluster(1).mean(1) mx];
                d=mean([csz(m1.cluster(5).cov),csz(m1.cluster(6).cov), csz(m1.cluster(1).cov)]);
                for i=5:6
                    c = m1.cluster(i).cov/sqrt(abs(det(m1.cluster(i).cov)))*d;
                    m1.cluster(i).cov=.1*beta(2)*m1.cluster(i).cov+(1-.1*beta(2))*c;
                end
            end
            % Define the ideal size of the cluster
            if options.max_cluster_size>0
                for i=1:3
                    c = m1.cluster(i).cov/sqrt(abs(det(m1.cluster(i).cov)))*options.max_cluster_size;
                    m1.cluster(i).cov=(beta(3))*m1.cluster(i).cov+(1-beta(3))*c;
                end
                c = m1.cluster(4).cov/sqrt(abs(det(m1.cluster(4).cov)))*options.max_cluster_size;
                m1.cluster(4).cov=beta(3)*m1.cluster(4).cov+(1-beta(3))*c*2;
                if length(m1.cluster)>5
                    for i=5:6
                        c = m1.cluster(i).cov/sqrt(abs(det(m1.cluster(i).cov)))*options.max_cluster_size;
                        m1.cluster(i).cov=(beta(3))*m1.cluster(i).cov+(1-beta(3))*c/2;
                    end
                end
            end
            % if cluster 11 is not active its position depends on 10 and 01
            if (m1.cluster(4).flag==0)
                center=.5*(m1.cluster(2).mean+m1.cluster(3).mean);
                corner=[m1.cluster(2).mean(1)  m1.cluster(3).mean(2)];
                m1.cluster(4).mean=.5*(center+corner);
            end
        end
end

% size of a gaussian
function s=csz(C)
    s=sqrt(abs(det(C)));
    
    
    function C=condcov(C,b)
% check for baddly conditionned cov matrix
a=sqrt(abs(det(C)));
if isnan(a) || isinf(a)
    disp('One covariance matrix was NaN. Reinitialization.');
    C=[5 0; 0 5];
else
    if a<b(1)
        %disp('-')
        C=C+b(1)*eye(size(C));
    elseif a>b(2)
        %disp('+')
        C=C./a*b(2);
    end
end