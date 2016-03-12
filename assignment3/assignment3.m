%load photos
image1 = imread('left1.jpg');
image2 = imread('right1.jpg');

%ask user for points on image1
figure, imagesc(image1);
axis image;
[x1, y1] = getpts;
close all;
points1 = [x1, y1];
%ask user for points on image2
figure, imagesc(image2);
axis image;
[x2, y2] = getpts;
close all;
points2 = [x2, y2];

H = calculateH(points1, points2);
T = maketform('projective', inv(H));

% obtain x & y data
[~, x_data, y_data] = imtransform(image2, T, 'XYScale', 1);
    
% update x/y data from the bounds
x_data = [min(1, x_data(1)), max(size(image1,2), x_data(2))];
y_data = [min(1, y_data(1)), max(size(image1,1), y_data(2))];

image2_transformed = imtransform(image1, T, 'XData', x_data, 'YData', y_data);
%image2_transformed = imtransform(image2, T);
figure, imagesc(image2_transformed);
axis image;