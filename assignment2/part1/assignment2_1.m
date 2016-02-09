%load image to copy
source_img = rgb2gray(im2double(imread('toygc.png')));

%display & save source image
imwrite(source_img,'source.jpg','quality',100);
figure, imagesc(source_img), colormap Gray;
axis image;

%map each pixel to a variable number
%variable number of pixel at y,x = im2var(y,x)
[imh, imw, nb] = size(source_img); 
im2var = zeros(imh, imw);
im2var(1:imh*imw) = 1:imh*imw;

%create matrix A & vector b
A = zeros(2*(imh-1)*(imw-1)+1, (imh-1)*(imw-1));
b = zeros(2*(imh-1)*(imw-1)+1, 1);

%iterate through each pixel
e = 0;
for y = 1:imh-1
   for x = 1:imw-1
       %objective1 : horizontal constraints 
       e=e+1; 
       A(e, im2var(y,x+1))=1; 
       A(e, im2var(y,x))=-1; 
       b(e) = source_img(y,x+1)-source_img(y,x);
       %objective1 : horizontal constraints
       e=e+1;
       A(e, im2var(y+1,x))=1; 
       A(e, im2var(y,x))=-1; 
       b(e) = source_img(y+1,x)-source_img(y,x);
       
   end
end

%objective 3
e=e+1; 
A(e, im2var(1,1))=1; 
b(e)=source_img(1,1); 

%solve for v in Av-b = 0
A = sparse(A);
v = A\b;

%copy each solved value to the appropriate pixel in the output image
finalImage = zeros((imh-1), (imw-1));
 for y = 1:imh-1
    for x = 1:imw-1
        finalImage(y,x) = v(im2var(y,x));
    end
 end

%display & save final image
imwrite(finalImage,'result.jpg','quality',100);
figure, imagesc(finalImage), colormap Gray;
axis image;