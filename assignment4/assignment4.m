%load photos
left_files = {'Lh (1).jpg', 'Lm (1).jpg', 'Ll (1).jpg'};
center_files = {'Ch (1).jpg', 'Cm (1).jpg', 'Cl (1).jpg'};
right_files = {'Rh (1).jpg', 'Rm (1).jpg', 'Rl (1).jpg'};

%create hdr photos
left_hdr = makehdr(left_files);
left_image = im2double(tonemap(left_hdr));
center_hdr = makehdr(center_files);
center_image = im2double(tonemap(center_hdr));
right_hdr = makehdr(right_files);
right_image = im2double(tonemap(right_hdr));

%ask user for points on left_image
figure, imagesc(left_image);
axis image;
[x1, y1] = getpts;
close all;
points1 = [x1, y1];

%ask user for points on center_image
figure, imagesc(center_image);
axis image;
[x2, y2] = getpts;
close all;
points2 = [x2, y2];

H = calculateH(points1, points2);
T = maketform('projective', H');

% obtain x & y data
[~, x_data, y_data] = imtransform(center_image, T, 'XYScale', 1);
     
% update x/y data from the bounds
x_data = [min(1, x_data(1)), max(size(left_image,2), x_data(2))];
y_data = [min(1, y_data(1)), max(size(left_image,1), y_data(2))];

%apply transformation to center_image
center_image_transformed = imtransform(center_image, T, 'XData', x_data, 'YData', y_data);

%transform left image with identity matrix. Puts left image in larger space
T_identity = maketform('projective',eye(3));
left_image_transformed = imtransform(left_image, T_identity, 'XData', x_data, 'YData', y_data);

%find range of x for which the images overlap
[~, y, ~] = size(left_image);
left_boundry = H(1,3);
[~, right_boundry, ~] = size(left_image);

%combine images into panorama
[height, width, depth] = size(left_image_transformed);
overlay = zeros(size(left_image_transformed));
foreground = zeros(size(left_image_transformed));
for d=1:depth
    for x=1:width
        for y=1:height
            if (x<right_boundry)
                overlay(y, x, d) = left_image_transformed(y, x, d);
            else
                overlay(y, x, d) = center_image_transformed(y, x, d);
            end 
        end
    end
end
for d=1:depth
    for x=1:width
        for y=1:height
            if (x>left_boundry)
                foreground(y, x, d) = center_image_transformed(y, x, d);
            else
                foreground(y, x, d) = left_image_transformed(y, x, d);
            end 
        end
    end
end
figure, imagesc(overlay);
axis image;
figure, imagesc(foreground);
axis image;

    panorama = zeros(size(left_image_transformed));
    
    
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

%%%%%%%%%%%%%%%%%%%
%%%%% round 2 %%%%%
%%%%%%%%%%%%%%%%%%%
center_image = right_image;
left_image = panorama;

%ask user for points on left_image
figure, imagesc(left_image);
axis image;
[x1, y1] = getpts;
close all;
points1 = [x1, y1];

%ask user for points on center_image
figure, imagesc(center_image);
axis image;
[x2, y2] = getpts;
close all;
points2 = [x2, y2];

H = calculateH(points1, points2);
T = maketform('projective', H');

% obtain x & y data
[~, x_data, y_data] = imtransform(center_image, T, 'XYScale', 1);
     
% update x/y data from the bounds
x_data = [min(1, x_data(1)), max(size(left_image,2), x_data(2))];
y_data = [min(1, y_data(1)), max(size(left_image,1), y_data(2))];

%apply transformation to center_image
center_image_transformed = imtransform(center_image, T, 'XData', x_data, 'YData', y_data);

%transform left image with identity matrix. Puts left image in larger space
T_identity = maketform('projective',eye(3));
left_image_transformed = imtransform(left_image, T_identity, 'XData', x_data, 'YData', y_data);

%find range of x for which the images overlap
[~, y, ~] = size(left_image);
left_boundry = H(1,3);
[~, right_boundry, ~] = size(left_image);

%combine images into panorama
[height, width, depth] = size(left_image_transformed);
overlay = zeros(size(left_image_transformed));
foreground = zeros(size(left_image_transformed));
for d=1:depth
    for x=1:width
        for y=1:height
            if (x<right_boundry)
                overlay(y, x, d) = left_image_transformed(y, x, d);
            else
                overlay(y, x, d) = center_image_transformed(y, x, d);
            end 
        end
    end
end
for d=1:depth
    for x=1:width
        for y=1:height
            if (x>left_boundry)
                foreground(y, x, d) = center_image_transformed(y, x, d);
            else
                foreground(y, x, d) = left_image_transformed(y, x, d);
            end 
        end
    end
end
figure, imagesc(overlay);
axis image;
figure, imagesc(foreground);
axis image;

    panorama = zeros(size(left_image_transformed));
    
    
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
imwrite(panorama,'threephotopano.jpg','quality',100);
figure, imagesc(panorama);
axis image;