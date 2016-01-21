I = imread('00889v.jpg'); %load image
%%% how to load images found by google: http://www.mathworks.com/help/matlab/import_export/importing-images.html
heightOfFrame = floor(size(I, 1) / 3); %automaticly get height of each negative
widthOfFrame = size(I, 2);

%seperate image into different channels
blue = I(1:heightOfFrame,:);
green = I(heightOfFrame+1:2*heightOfFrame,:);
red = I(2*heightOfFrame+1:3*heightOfFrame,:);

%crop in by 25 pixles on all frames
cropped_red = red(25:heightOfFrame-25, 25:widthOfFrame-25);

%align blue to red
x_cords = int16.empty(625, 0);
y_cords = int16.empty(625, 0);
z_cords = int16.empty(625, 0);
i = 1;
for dx = -12:12
    for dy = -12:12
        cropped_blue = blue((25+dy):heightOfFrame-25+dy, 25+dx:widthOfFrame-25+dx);
        tmp = ssd(cropped_red, cropped_blue);
        x_cords(i) = dx;
        y_cords(i) = dy;
        z_cords(i) = tmp;
        i = i+1;
    end
end
%find optimum offsets and crop
figure, scatter3(x_cords, y_cords, z_cords);
[m, min_index] = min(z_cords);
dx = x_cords(min_index);
dy = y_cords(min_index);
cropped_blue = blue((25+dy):heightOfFrame-25+dy, 25+dx:widthOfFrame-25+dx);

%align green to red
x_cords = int16.empty(625, 0);
y_cords = int16.empty(625, 0);
z_cords = int16.empty(625, 0);
i=1;
for dx = -12:12
    for dy = -12:12
        cropped_green = green((25+dy):heightOfFrame-25+dy, 25+dx:widthOfFrame-25+dx);
        tmp = ssd(cropped_red, cropped_green);
        x_cords(i) = dx;
        y_cords(i) = dy;
        z_cords(i) = tmp;
        i = i+1;
    end
end
%find optimum offsets and crop
figure, scatter3(x_cords, y_cords, z_cords);
[m, min_index] = min(z_cords);
dx = x_cords(min_index);
dy = y_cords(min_index);
cropped_green = green((25+dy):heightOfFrame-25+dy, 25+dx:widthOfFrame-25+dx);

mergedImage = cat(3,cropped_red,cropped_green,cropped_blue);

%display image
%%from sample code
figure, imagesc(mergedImage);
axis image;
figure, imagesc(cropped_red);
axis image;
figure, imagesc(cropped_green);
axis image;
figure, imagesc(cropped_blue);
axis image;


%write the image
%imwrite(mergedImage,'result1_v1.tif','quality',100);



