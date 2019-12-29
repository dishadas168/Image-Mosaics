% This function takes as input an image inputIm, a reference image refIm, 
% and a 3x3 homography matrix H, and returns 2 images as outputs. The first 
% image is warpIm, which is the input image inputIm warped according to H 
% to be in the frame of the reference image refIm. The second output image 
% is mergeIm, a single mosaic image with a larger field of view containing 
% both the input images. To avoid holes, an inverse warp is used. 

function [ warpIm, mergeIm ] = warpImage( inputIm, refIm, H )
 
im1 = inputIm;
im2 = refIm;
figure;
imshow(im1);
title('Input image');
figure;
imshow(im2);
title('Reference image');


%Finding offset values for height and weight
ctl = H*[1,1,1].';
ctl = ctl/ctl(3,:);
ctr = H*[1,size(im1,2),1].';
ctr = ctr/ctr(3,:);
cbl = H*[size(im1,1),1,1].';
cbl = cbl/cbl(3,:);
cbr = H*[size(im1,1),size(im1,2),1].';
cbr = cbr/cbr(3,:);
xs = [ctl(1), ctr(1), cbl(1), cbr(1)];
[xstart, minx] = min(xs);
xend = max(xs);
ys = [ctl(2,:), ctr(2,:), cbl(2,:), cbr(2,:)];
[ystart, miny] = min(ys);
yend = max(ys);


Rheight = round(yend - ystart) + size(im2,2) + size(im1,2);
Rwidth = round(xend - xstart) + size(im2,1) + size(im1,1);
offseth= abs(xs(minx));
offsetw= abs(ys(miny));


%Meshgrid results, xi yi, to be filled by transform values. Used in interp2.
[xi,yi] = meshgrid(1:Rheight,1:Rwidth);
[x,y] = meshgrid(1:size(im1,2),1:size(im1,1));

for i = 1:Rwidth
    for j = 1:Rheight
        g = inv(H)*[i-offseth,j-offsetw,1].';
        g = g/g(3,:);
        i2 = g(1,:);
        j2 = g(2,:);
        xi(i,j) = j2;
        yi(i,j) = i2;
  
    end
end


%Inverse mapping
newimR = interp2(x,y,double(im1(:,:,1)),xi,yi);
newimG = interp2(x,y,double(im1(:,:,2)),xi,yi);
newimB = interp2(x,y,double(im1(:,:,3)),xi,yi);
newim = cat(3, newimR, newimG, newimB);
newim = uint8(newim);

warpIm = newim;
% figure;
% imshow(uint8(warpIm));

%Creation of bounding box for warpIm
p1 = [round(ctl(1) + offseth)+1, round(ctl(2) + offsetw) + 1];
p2 = [round(ctr(1) + offseth)+1, round(ctr(2) + offsetw) + 1];
p3 = [round(cbr(1) + offseth)+1, round(cbr(2) + offsetw) + 1];
p4 = [round(cbl(1) + offseth)+1, round(cbl(2) + offsetw) + 1];
warpIm = insertShape(warpIm,'polygon',[p1(2),p1(1),p2(2),p2(1),p3(2),p3(1),p4(2),p4(1)],'LineWidth',5);
% figure;
% imshow(warpIm);

%Cropping out black areas
for i = size(warpIm,1):-1:1
    m = max(warpIm(i,:,1));
   if m==0
       warpIm(i,:,:) = [];
   end
end
for i = size(warpIm,2):-1:1
    m = max(warpIm(:,i,1));
   if m==0
       warpIm(:,i,:) = [];
   end
end
% figure;
% imshow(warpIm);
% title('Warped Image');

%Overlapping two images
areanewim = size(newim(newim>0),1);
areaim2 = size(im2(im2>0),1);
if areanewim > areaim2
    for i = 1:size(im2,1)
        for j= 1:size(im2,2)
            newim(round(i+offseth)+1,round(j+offsetw)+1,:) = im2(i,j,:);
        end
    end
else
    newim2 = im2;
    for i = 1:size(newim,1)
        for j = 1:size(newim,2)
            if newim(i,j)>0
                newim2(round(i+offseth)+1,round(j+offsetw)+1,:) = newim(i,j,:);
            end
        end
    end
    newim = newim2;
end
    


%Creation of bounding box
newim = insertShape(newim,'polygon',[p1(2),p1(1),p2(2),p2(1),p3(2),p3(1),p4(2),p4(1)],'LineWidth',5);


%Cropping away black areas.
for i = size(newim,1):-1:1
    m = max(newim(i,:,1));
   if m==0
       newim(i,:,:) = [];
   end
end
for i = size(newim,2):-1:1
    m = max(newim(:,i,1));
   if m==0
       newim(:,i,:) = [];
   end
end
mergeIm = newim;


end

