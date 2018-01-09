
% Analysis the light intensity change on the sepecific area according to a
% series of image taken from EMCCD.
% 01/04/2018 in ANE lab at Auburn University

clear all; close all; clc;
addpath('bfmatlab'); % add DIP analyt libary
fid = bfopen('*'); % open a series of images

% set up parameters
spotAreaSize = 30; % def the size of SPOT area 
testAreaSize = 300; % def the size of TEST area 
xTAxis = 50+200; % relative x-Axis distance
yTAxis = 50+200;% relative y-Axis distance

sizeX = 512;
sizeY = sizeX; 

seriesl = fid{1, 1};
stop_frame = size(seriesl, 1); 
start_frame = 1;
nSeries1 = stop_frame - start_frame + 1; % total NUM of the images

planeT = uint16(0);
planeT(sizeX,sizeY,nSeries1) = 0;
for i=1:nSeries1
    planeT(:,:,i) = seriesl{start_frame+i-1, 1};
end

plane1=squeeze(planeT(:,:,1)); % extract the first image

[A,rect] = imcrop(plane1,[]); % choose an specific area on the plane1
value = max(max(A)); % find the brightest spot on the specific area
[rowA, colA] = find(value == A); 
col1 = colA + rect(1)/2;
row1 = rowA + rect(2)/2; % def the coordinate of the SPOT on the plane1

% TEST Area
centralxy1 = [(col1 + xTAxis) (row1 + yTAxis)]; % central XYaxis of the test area
barWidth = testAreaSize;
barx1 = centralxy1(1) - (barWidth - 1)/2;
bar_top1 = row1 + yTAxis + (testAreaSize-1)/2;
bar_bottom1 = row1 + yTAxis -(testAreaSize-1)/2;

figure()
imshow(plane1, []);
hold on
plot(col1, row1, 'r*') % show the brightest spot

% Spot Area Frame
plot([col1 - spotAreaSize/2 col1 - spotAreaSize/2], [row1 - spotAreaSize/2 row1 + spotAreaSize/2], 'r', 'LineWidth', 1)
plot([col1 + spotAreaSize/2 col1 + spotAreaSize/2], [row1 - spotAreaSize/2 row1 + spotAreaSize/2], 'r', 'LineWidth', 1)
plot([col1 - spotAreaSize/2 col1 + spotAreaSize/2], [row1 + spotAreaSize/2 row1 + spotAreaSize/2], 'r', 'LineWidth', 1)
plot([col1 - spotAreaSize/2 col1 + spotAreaSize/2], [row1 - spotAreaSize/2 row1 - spotAreaSize/2], 'r', 'LineWidth', 1)

% Test Area Frame
plot([centralxy1(1)-((barWidth-1)/2) centralxy1(1)-((barWidth-1)/2)], [bar_top1 bar_bottom1], 'r', 'LineWidth', 1)
plot([centralxy1(1)+((barWidth-1)/2) centralxy1(1)+((barWidth-1)/2)], [bar_top1 bar_bottom1], 'r', 'LineWidth', 1)
plot([centralxy1(1)-((barWidth-1)/2) centralxy1(1)+((barWidth-1)/2)], [bar_top1 bar_top1], 'r', 'LineWidth', 1)
plot([centralxy1(1)-((barWidth-1)/2) centralxy1(1)+((barWidth-1)/2)], [bar_bottom1 bar_bottom1], 'r', 'LineWidth', 1)

title('spot area and test area ');
hold off;

% def the COOR of the SPOT area 
xMin = col1 - (spotAreaSize - 1)/2;
yMin = row1 - (spotAreaSize - 1)/2;
width = spotAreaSize;
height = spotAreaSize;
defRectSpot = [xMin yMin width-1 height-1];

testAreaData = zeros(testAreaSize*(testAreaSize), nSeries1);
absI = zeros(testAreaSize*(testAreaSize),nSeries1);
BW = zeros(sizeX,sizeY);
I_testArea(testAreaSize,testAreaSize,nSeries1) = 0;

for i = 1:nSeries1
    
    value = max(max(imcrop(planeT(:,:,i), defRectSpot))); % find the brightest spot on cropArea
    [row, col] = find(value == planeT(:,:,i)); % the coor of the spot
    
    % def the COOR of the test area
    centralxy = [(col + xTAxis) (row + yTAxis)]; % test area central point
    xMinTest = centralxy(1) - (testAreaSize - 1)/2;
    yMinTest = centralxy(2) - (testAreaSize - 1)/2;
    widthTest = testAreaSize;
    heightTest = testAreaSize;
    defRectTest = [xMinTest yMinTest widthTest-1 heightTest-1];
    
    I_testArea = imcrop(planeT(:,:,i), defRectTest);
    
    absI(:,i) = mean(mean(I_testArea));   
end


figure()
 plot(1:nSeries1,absI,'LineStyle','none','Marker','.');
%  legend('Background','Area1','Area2','Area3','Area4');
 title('IL-6 1000pg/mL dI for The Area of Intensity Increase')

tic; toc 
