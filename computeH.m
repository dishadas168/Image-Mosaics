% This function takes a set of corresponding image points t1, t2 (both t1 
% and t2 are 2xN matrices) and computes the associated 3 x 3 homography 
% matrix H.

function [ H ] = computeH( t1, t2 )

    if size(t1,2)<4 | size(t2,2)<4
        error('Enter more than 4 coordinates');
    end
  
    t1([1 2],:)=t1([2 1],:);
    t2([1 2],:)=t2([2 1],:);
    x = size(t1,2);
    P = zeros(1,9);
    for i = 1:x
        xA = t1(1,i);
        yA = t1(2,i);
        xB = t2(1,i);
        yB = t2(2,i);
        p = zeros(2,9);
        p(1,:) = [-xA, -yA, -1, 0,0,0, xA*xB, yA*xB, xB];
        p(2,:) = [0,0,0, -xA, -yA, -1, xA*yB, yA*yB, yB];
        P = [P ; p];
    end
    P(1,:) = [];
    x = [0,0,0,0,0,0,0,0,1];
    P = [P;x];
    [U,D,V] = svd(P);
    H = V(:,end);
    H= (reshape(H,3,3)).';
    
end

