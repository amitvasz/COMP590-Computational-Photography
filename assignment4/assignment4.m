%load photos
image1 = im2double(imread('left2.jpg'));
image2 = im2double(imread('right2.jpg'));

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
T = maketform('projective', H');

% obtain x & y data
[~, x_data, y_data] = imtransform(image2, T, 'XYScale', 1);
     
% update x/y data from the bounds
x_data = [min(1, x_data(1)), max(size(image1,2), x_data(2))];
y_data = [min(1, y_data(1)), max(size(image1,1), y_data(2))];

%apply transformation to image 2
image2_transformed = imtransform(image2, T, 'XData', x_data, 'YData', y_data);

%transform image 1 with identity matrix. Puts image 1 in larger space
T_identity = maketform('projective',eye(3));
image1_transformed = imtransform(image1, T_identity, 'XData', x_data, 'YData', y_data);

%find range of x for which the images overlap
[~, y, ~] = size(image1);
left_boundry = H(1,3);
[~, right_boundry, ~] = size(image1);

%combine images into panorama
[height, width, depth] = size(image1_transformed);
overlay = zeros(size(image1_transformed));
foreground = zeros(size(image1_transformed));
for d=1:depth
    for x=1:width
        for y=1:height
            if (x<right_boundry)
                overlay(y, x, d) = image1_transformed(y, x, d);
            else
                overlay(y, x, d) = image2_transformed(y, x, d);
            end 
        end
    end
end
for d=1:depth
    for x=1:width
        for y=1:height
            if (x>left_boundry)
                foreground(y, x, d) = image2_transformed(y, x, d);
            else
                foreground(y, x, d) = image1_transformed(y, x, d);
            end 
        end
    end
end
figure, imagesc(overlay);
axis image;
figure, imagesc(foreground);
axis image;

    panorama = zeros(size(image1_transformed));
    
    
    %map each pixel to a variable number
    %variable number of pixel at y,x = im2var(y,x)
    im2var = zeros(height, width);
    im2var(1:height*width) = 1:height*width;

    %create matrix A & vector b
    A = sparse((height)*(width), (height)*(width));
    b = zeros((height)*(width), 1);
    
    
    d = 0;
    for d=1:depth
        e = 0;
        for y = 1:height
            for x = 1:width
                e=e+1;
                if (x >= left_boundry && x <= right_boundry && y>1 && y<height) %if pixel is in overlapping region, laplacian 
                    A(e, im2var((y),(x))) = 4;
                    A(e, im2var((y-1),(x))) = -1;
                    A(e, im2var((y+1),(x))) = -1;
                    A(e, im2var((y),(x-1))) = -1;
                    A(e, im2var((y),(x+1))) = -1;
                    b(e) = 4*overlay(y,x,d)-overlay(y-1,x,d)-overlay(y+1,x,d)-overlay(y,x+1,d)-overlay(y,x-1,d);
                else %else, copy directly from background
                    A(e,im2var((y),(x))) = 1;
                    b(e) = foreground(y,x,d);
                end
            end
        end
    %objective 3
    e=e+1; 
    A(e, im2var(1,1))=1; 
    b(e)=foreground(1,1,d); 

    %solve for v in Av-b = 0
    v = A\b;
   
    %copy each solved value to the appropriate pixel in the output image
    for y = 1:height
        for x = 1:width
            %%modified to be weighted average of new value and original
            %%value
            if (x>=left_boundry && x<=right_boundry)
                weight = (x-left_boundry)/(right_boundry-left_boundry);
            else
                weight = 0;
            end
            panorama(y,x,d) = v(im2var(y,x))*(1-weight) + foreground(y,x,d)*weight;
        end
    end
end


%display panorama
figure, imagesc(panorama);
axis image;