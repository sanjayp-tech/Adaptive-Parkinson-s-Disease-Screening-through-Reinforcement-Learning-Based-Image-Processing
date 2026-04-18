
function seg=segment(F)

% Step 1: Read in the Color Image and Convert it to Grayscale
%% 


X=F;
rgbI=X;


labTransformation = makecform('srgb2lab');
labI = applycform(rgbI,labTransformation);

%seperate l,a,b
l = labI(:,:,1);
a = labI(:,:,2);
b = labI(:,:,3);

aaa= l;
aaa=edge(aaa,'canny',[0.1278 0.17]);
%aaa=edge(aaa,'sobel',0.0354);    

[~,~,~]=size(X);     
   
 

 
 %%% then initial  the contour  
 %% 
 [~,s,i]=rgb2hsv(X);
s=adapthisteq(s);
%  figure,imshow(s)
%   figure,imshow(s-i)
%  figure,imshow(im2bw(s-i,0.000001))
Img1=~double(bwareaopen(im2bw(s-i,0.000001),50));
X=double(X);

F=im2double(F);

%Converting RGB image to Intensity Image
%% 
r=F(:,:,1);
g=F(:,:,2);
b=F(:,:,3);
I=(r+g+b)/3;
% imshow(I);

%Applying Gradient
%% 
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
 figure, imshow(gradmag,[]), title('Feature extracted image (GLCM)');

L = watershed(gradmag);
Lrgb = label2rgb(L);
%figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)');

se = strel('disk',20);
Io = imopen(I, se);
% figure, imshow(Io), title('Opening (Io)');
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
 figure, imshow(Iobr), title('reconstructed image');

Ioc = imclose(Io, se);
 %figure, imshow(Ioc), title('Opening-closing (Ioc)');

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% figure, imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)');

fgm = imregionalmin(Iobrcbr);
%figure, imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)');

I2 = I;
I2(fgm) = 255;
 %figure, imshow(I2), title('Regional maxima superimposed on original image (I2)');

se2 = strel(ones(7,7));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
%figure, imshow(I3), title('Modified regional maxima superimposed on original image (fgm4)');

bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
%figure, imshow(bw), title('Thresholded opening-closing by reconstruction (bw)');

Z=imcomplement(bw);
Dil=imdilate(Z,strel('disk',30));
% figure
% imshow(Z)

pixel_labels1=bwlabel(Z);



SD=zeros(size(pixel_labels1));
s  = regionprops(pixel_labels1, 'Area');
ARE=max([s(:).Area]);
TT=find([s(:).Area]==ARE);

SD(pixel_labels1==TT)=1;
Z=SD;
Z=double(Z);
s1  = regionprops(logical(Z), 'Boundingbox');

X1(:,:,1)=X(:,:,1).*Z;
X1(:,:,2)=X(:,:,2).*Z;
X1(:,:,3)=X(:,:,3).*Z;

X1=imcrop(X1,s1.BoundingBox);
seg=X1;
figure 
imshow(uint8(X1(:,:,:)));
title('Segmentation')
