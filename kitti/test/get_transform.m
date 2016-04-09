function [T, max_inliers, avg_residual,max_I] = get_transform(x1, y1, x2, y2,display_flag)

	% Do RANSAC to determine the best transformation between the matched coordinates
	% provided by (x1,y1,x2,y2).

	% Return the transformation, the number of inliers, and average residual
    %modification : return indices of inliers instead of x1_in,y1_in,x2_in,y2_in
    n=size(x1,1);
    max_inliers=0;
    iterations=100;
    residual=zeros(iterations,1);
    %---------------RANSAC----------------------------------------------
    for RANSAC=1:iterations
    %choose 4 random integers between 1 and size of either x1,y1,x2,y2
    
    random_index=randi([1 size(x1,1)],4,1);
    %do svd and get homogenous transformation matrix to transform X2 to X1
    X2=[x2(random_index),y2(random_index),ones(size(random_index))];
    A=zeros(2*size(random_index,1),9);
    for i=1:size(random_index);
        A(2*i-1,4:6)=X2(i,:);
        A(2*i-1,7:9)=-y1(random_index(i))*X2(i,:);
        A(2*i,1:3)=X2(i,:);
        A(2*i,7:9)=-x1(random_index(i))*X2(i,:);
    end
    
    [U,S,V]=svd(A);
    h=V(:,end);
    
    T=[h(1:3)';h(4:6)';h(7:9)'];
    
     %apply the transform on each x2,y2 and find the dist2 between x2,y2
    %after transform and x1,y1. Threshold this distance
    X2=[x2'; y2'; ones(size(x2'))]; %different columns represent points
    X2new=T*X2; %different columns represent points [x;y;z]
    X2new=X2new./repmat(X2new(3,:),[3 1]);
    Dist=zeros(n,1);
    for i=1:n
    Dist(i)=dist2(X2new(1:2,i)',[x1(i) y1(i)]);
    end
    %get inliers
    threshold=2;
    I=find(Dist<threshold);
    num_inliers=size(I,1);
    
    residual(RANSAC)=sum(Dist(I));%residual sum of inlier squared distances.
    
    
    if(num_inliers>max_inliers)
        max_inliers=num_inliers;
        %max_T=T;
        max_I=I;
        best_iteration=RANSAC;
    end
    max_inliers_plot(RANSAC)=max_inliers;
   
    
    
    end
    
    %}
    %_____________________
   
    
    
    
X2=[x2(max_I),y2(max_I),ones(size(max_I))];
    n=size(max_I,1);
    A=zeros(2*n,9);
    for i=1:n;
        A(2*i-1,4:6)=X2(i,:);
        A(2*i-1,7:9)=-y1(max_I(i))*X2(i,:);
        A(2*i,1:3)=X2(i,:);
        A(2*i,7:9)=-x1(max_I(i))*X2(i,:);
    end
    [U,S,V]=svd(A);
    h=V(:,end);
    
    T=[h(1:3)';h(4:6)';h(7:9)'];
  
    
    
    avg_residual=residual(best_iteration)/max_inliers;
    if(display_flag)
    figure()
     plot(1:iterations,max_inliers_plot)
    end
    x1_in=x1(max_I);
    y1_in=y1(max_I);
    x2_in=x2(max_I);
    y2_in=y2(max_I);
end
