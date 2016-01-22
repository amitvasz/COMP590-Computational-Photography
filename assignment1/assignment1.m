I = imread('00889v.jpg'); %load image

%automaticly get height of each negative
heightOfFrame = floor(size(I, 1) / 3); 

%seperate image into different channels
blue = I(1:heightOfFrame,:);
green = I(heightOfFrame+1:2*heightOfFrame,:);
red = I(2*heightOfFrame+1:3*heightOfFrame,:);

%align images
%% found example in image processing toolbox documentation: http://www.mathworks.com/company/newsletters/articles/automating-image-registration-with-matlab.html
%% also used documentation found here : http://www.mathworks.com/help/images/ref/imregister.html
[optimizer,metric] = imregconfig('multimodal');
mgreen = imregister(green, red, 'Similarity', optimizer, metric);
mblue = imregister(blue, red, 'Similarity', optimizer, metric);

%display image
mergedImage = cat(3,red,mgreen,mblue);
figure, imagesc(mergedImage);
axis image;

%write the image
imwrite(mergedImage,'result3_v1.jpg','quality',100);
