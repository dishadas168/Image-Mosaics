%Script to choose corresponding points between two images and store the 
%coordinates in a mat file

clc
clear

im1 = imread('wdc1.jpg');
im2 = imread('wdc2.jpg');
imshow(im1);
hold on;
[x y] = ginput(4);
hold off;
imshow(im2);
hold on;
[x1 y1] = ginput(4);
hold off;
points1 = [x,y].';
points2 = [x1,y1].';
save('points.mat','points1', 'points2');