I = imread('00889v.jpg'); %load image

%automaticly get height of each negative
heightOfFrame = floor(size(I, 1) / 3);
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
%find optimum offsets and crop blue channel
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
%find optimum offsets and crop green channel
figure, scatter3(x_cords, y_cords, z_cords);
[m, min_index] = min(z_cords);
dx = x_cords(min_index);
dy = y_cords(min_index);
cropped_green = green((25+dy):heightOfFrame-25+dy, 25+dx:widthOfFrame-25+dx);

%display color image
mergedImage = cat(3,cropped_red,cropped_green,cropped_blue);
figure, imagesc(mergedImage);
axis image;

%write the image
imwrite(mergedImage,'result2_v2.jpg','quality',100);



