I = imread('01044u.tif'); %load image
%%% how to load images found by google: http://www.mathworks.com/help/matlab/import_export/importing-images.html
heightOfFrame = floor(size(I, 1) / 3); %automaticly get height of each negative

%seperate image into different channels
blue = I(1:heightOfFrame,:);
green = I(heightOfFrame+1:2*heightOfFrame,:);
red = I(2*heightOfFrame+1:3*heightOfFrame,:);

%align images
%% found example in image processing toolbox documentation: http://www.mathworks.com/company/newsletters/articles/automating-image-registration-with-matlab.html
%% also used documentation found here : http://www.mathworks.com/help/images/ref/imregister.html
[optimizer,metric] = imregconfig('multimodal');
mgreen = imregister(green, red, 'affine', optimizer, metric);
mblue = imregister(blue, red, 'affine', optimizer, metric);

mergedImage = cat(3,red,mgreen,mblue);

%display image
%%from sample code
figure, imagesc(mergedImage);
axis image;

%analyze quality
%%crop in to center of frame using Ic command. Use cropped frames to
%%analyze
[ssimval, ssimmap] = ssim(mgreen,red);
fprintf('The SSIM value is %0.4f.\n',ssimval);
err = immse(mgreen, red);
fprintf('\n The mean-squared error is %0.4f\n', err);

%write the image
imwrite(mergedImage,'result1.jpg','quality',100);
