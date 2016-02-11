%load images
background_img = im2double(imread('moon_source.png'));
foreground_img = im2double(imread('penguin_source.png'));
binary_mask = round(im2double(imread('binary_mask.png')));
mask_feathered = im2double(imread('mask_feathered.png'));

%%%%%%%%%%%%%%%%%
%%%% cloning %%%%
%%%%%%%%%%%%%%%%%

%create empty final image of the correct size
cloned_image = zeros(size(background_img));
[height, width, depth] = size(background_img);

%clone based on binary mask
for d=1:depth
   for y = 1:height
      for x = 1:width
         if (binary_mask(y,x) >.5) %if mask is 1, copy from foreground
             cloned_image(y,x,d) = foreground_img(y,x,d);
         else
             cloned_image(y,x,d) = background_img(y,x,d);
         end
      end
   end
end

%display & save cloned image
imwrite(cloned_image,'cloned_image_large.jpg','quality',100);
figure, imagesc(cloned_image);
axis image;

%clone with alpha mask blending
for d=1:depth
   for y = 1:height
      for x = 1:width
         cloned_image(y,x,d) = foreground_img(y,x,d)*mask_feathered(y,x) + background_img(y,x,d)*(1-mask_feathered(y,x));
      end
   end
end

%display & alpha blended image
imwrite(cloned_image,'alpha_blend_image_large.jpg','quality',100);
figure, imagesc(cloned_image);
axis image;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Gradient Domain Blending %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create empty final image of the correct size
final_image = zeros(size(background_img));

%map each pixel to a variable number
%variable number of pixel at y,x = im2var(y,x)
im2var = zeros(height, width);
im2var(1:height*width) = 1:height*width;

%create matrix A & vector b
A = sparse((height)*(width), (height)*(width));
b = zeros((height)*(width), 1);

%iterate through each pixel
d = 0;
for d=1:depth
   e = 0;
   for y = 1:height
      for x = 1:width
              e=e+1;
          if (mask_feathered(y,x) > .5) %if mask is 1, laplacian 
              A(e, im2var((y),(x))) = 4;
              A(e, im2var((y-1),(x))) = -1;
              A(e, im2var((y+1),(x))) = -1;
              A(e, im2var((y),(x-1))) = -1;
              A(e, im2var((y),(x+1))) = -1;
              %b(e) = cloned_image(y,x,d);
              b(e) = 4*foreground_img(y,x,d)-foreground_img(y-1,x,d)-foreground_img(y+1,x,d)-foreground_img(y,x+1,d)-foreground_img(y,x-1,d);
          else %else, copy directly from background
              A(e,im2var((y),(x))) = 1;
              b(e) = background_img(y,x,d);
          end
      end
   end
   %objective 3
   e=e+1; 
   A(e, im2var(1,1))=1; 
   b(e)=background_img(1,1,d); 

   %solve for v in Av-b = 0
   v = A\b;
   
   %copy each solved value to the appropriate pixel in the output image
   for y = 1:height
       for x = 1:width
           final_image(y,x,d) = v(im2var(y,x));
       end
   end
end

%display & save final image
imwrite(final_image,'seamless_cloning_large.jpg','quality',100);
figure, imagesc(final_image);
axis image;

