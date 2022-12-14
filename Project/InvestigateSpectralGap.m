clear all;

for p=.05:.05:.5
    
    p_G1 = 0.1 + p;
    p_G2 = 0.25 + p;
    
    gaps = zeros(10,1);
    gcf = figure;  
    hold on;
   
    legendCount =1;
    ClusterSize=512
    legendStrings{legendCount} = ['N = ',sprintf('%d',ClusterSize)];legendCount = legendCount+1;        
    K=20
    xVals=nan(K,1);        
    for i=1:K
        N=2*  ClusterSize;
        x = (1:N);%randperm(N);
        gs = N/2;
        G1 = x(1:gs);
        G2 = x(gs+1:2*gs);
        p_Inbetween = 0.000 + (i-1)/(10*K);
        xVals(i) = p_Inbetween;
        A(G1, G1) = rand(gs,gs) < p_G1;
        A(G2, G2) = rand(gs,gs) < p_G2;
        [n1,m1]=size( A(G1, G2));
        B_1=rand(gs, gs);
        A(G1, G2) = B_1 < p_Inbetween;
        A = triu(A,1);
        A = A + A';
        
        L2=sgwt_laplacian(A);
        sigma=eig(L2);
        gap = sigma(2)-sigma(1);
        
        gaps(i)= gap;          
    end
    plot(xVals,gaps);
       

    legend(legendStrings,'Location','SE');
    title({['Spectral Gap 2 Class Ensemble '];[' p(Class1)= ',sprintf('%f',p_G1),' p(Class2)= ',sprintf('%f',p_G2)]});
    xlabel('p(Class2  ~ Class1)');
    ylabel('\lambda_2 - \lambda_1');
    print(gcf,'-djpeg','-r600', ['./results/SpectralGap_P1_',sprintf('%f',p_G1),'P2_',sprintf('%f',p_G2),'.jpg'] );
    close gcf;    
end


clear all;
p=.05
p_G1 = 0.05 + p;
p_G2 = 0.15 + p;    
clusterSizeStart = 128;
clusterSizeDelta = 64;
clusterSizeMax = 512;%Calculate These
ClusterSize=clusterSizeStart
M=10;
xp1=nan(M,1);
xp2=nan(M,1);
xcrosstalk=nan(M,1);
xgap=nan(M,1);
xcond1=nan(M,1);
xcond2=nan(M,1);
xcond12=nan(M,1);


for i=1:M
    N=2*  ClusterSize;
    x = (1:N);%randperm(N);
    gs = N/2;
    G1 = x(1:gs);
    G2 = x(gs+1:2*gs);
    p_Inbetween = 0.000 + (i-1)/100;
    A(G1, G1) = rand(gs,gs) < p_G1;
    A(G2, G2) = rand(gs,gs) < p_G2;
    [n1,m1]=size( A(G1, G2));
    B_1=rand(gs, gs);
    A(G1, G2) = B_1 < p_Inbetween;
    A = triu(A,1);
    A = A + A';
    
    L2=sgwt_laplacian(graph(A));
    L2s = sgwt_laplacian_xrx(A);%same!
    
    sigma=eig(L2);
    gap = sigma(2)-sigma(1);
    spy(A);
    print('-djpeg','-r600', ['./results/Aspy_P1_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.jpg'] );
    close gcf;

    XY_fr=fruchterman_reingold_force_directed_layout(sparse(A*1.0),'initial_temp',50);
    wgPlot(A,XY_fr); 
    print('-djpeg','-r600', ['./results/G_P1_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.jpg'] );
    close gcf;
    
    L_G1 = sgwt_laplacian(graph(A(1:gs, 1:gs)))
    L_G2=sgwt_laplacian(graph(A(gs+1:2*gs, gs+1:2*gs)))
    sigmaG1 = eig(L_G1)
    sigmaG2 = eig(L_G2)            
    sigmaX = [sigmaG1;sigmaG2]
    close gcf;
    plot(sigma,"Marker","+")
    hold on;
    plot(sigmaX,"Color",'red','Marker','*')
    %Same as eig - safety check
    %sigmaSVD=sort(svd(L2),1,"ascend")
    %plot(sigmaSVD,"Color",'green','Marker','square')
    print('-djpeg','-r600', ['./results/Spectrum_P1_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.jpg'] );
    close gcf;
    
    L2=sgwt_laplacian_xrx(A);
    [V,D] = eigs(L2,16,'SA');
    figure ; plot(sort(V(:,1)), 'c');hold on;
    plot(sort(V(:,2)), 'b');
    plot(sort(V(:,3)), 'r');
    plot(sort(V(:,4)), 'g');
    title('First Four Eigenvectors of Graph sgwt_laplacian')
    legend('EV 0','EV1','EV 2','EV 3');
    print('-djpeg','-r600', ['./results/EigenVectors_P1_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.jpg'] );
    close gcf;

    s = condeig(L2);
    plot(s)
    title('Eigenvalue condition number')
    print('-djpeg','-r600', ['./results/EV_cond_P1_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.jpg'] );
    close gcf;
   
    xp1(i)=p_G1;
    xp2(i)=p_G2;
    xcrosstalk(i)=p_Inbetween;
    xgap(i)=gap;
    xcond1(i)=cond(sgwt_laplacian(graph(A(1:gs, 1:gs))));
    xcond2(i)=cond(sgwt_laplacian(graph(A(gs+1:2*gs, gs+1:2*gs))));
    xcond12(i)=cond(L2); 

end

dataTable = table(xp1,xp2,xcrosstalk,xgap,xcond1,xcond2,xcond12,'VariableNames',{'pClass1','pClass2','pClass12','EigenGap12','cond1','cond2','cond12'});
filename=['./results/DataTable_',sprintf('%f',p_G1),'_P2_',sprintf('%f',p_G2),'_crosstalk_',sprintf('%f',p_Inbetween),'_gap_',sprintf('%f',gap),'.csv']
writetable(dataTable,filename)
disp(dataTable)





clear all;
% - ------------------ Create Synthetic 2 Class 2D Data 

dx = 10

mu1 = [-20 0];
sigma1 = [3 .4; .4 3];

mu2 = [-20+dx 0];
sigma2 = [3 0; 0 3];

X1=[mvnrnd(mu1,sigma1,1000)];
X2=[mvnrnd(mu2,sigma2,1000)];
X=[X1;X2];

% - ------------------ Plot Data 
figure ;set(gcf,'color','w');
hold on;

scatter(X1(:,1),X1(:,2),'b','.');
scatter(X2(:,1),X2(:,2),'g','.');

gm = gmdistribution.fit(X1,1);
ezcontour(@(x,y)pdf(gm,[x y]),[-30 0],[-10 10],160);
covX1 = cov(X1);
quiver(mu1(1),mu1(2) ,covX1(1,1),covX1(2,1),'b');
quiver(mu1(1),mu1(2) ,covX1(1,2),covX1(2,2),'b');

gm = gmdistribution.fit(X2,1);
ezcontour(@(x,y)pdf(gm,[x y]),[-30 0],[-10 10],160);
covX2 = cov(X2);
quiver(mu2(1),mu2(2) ,covX2(1,1),covX2(2,1),'g');
quiver(mu2(1),mu2(2) ,covX2(1,2),covX2(2,2),'g');

print('-dpng','-r600', ['./results/2class_data_example_dx10.png'] );
close gcf;




% - --------
clear all;
A=[0 1 0 0 1 0;1 0 1 0 1 0;0 1 0 1 0 0 ; 0 0 1 0 1 1;1 1 0 1 0 0;0 0 0 1 0 0]
G = graph(A)
D = diag(degree(G));
L= sgwt_laplacian(G);
plot(G)

disp(A)
disp(full(D))
disp(full(L))




