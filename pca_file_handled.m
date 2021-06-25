clear;
close all;
clc;

filePath = input("Enter the path: ");
im = imread(filePath);

%to get the extension of file so that pictures can be saved in the same
%extension
[~,fName,ext] = fileparts(which(filePath));

%to reduce clutter, make a new folder as per user's wish and store all the
%related files there
folderName = input("Enter the folder name you want to save all the related images: ");
mkdir(folderName);

imshow(im)

%put the original image in a frame and put it to the new folder
title('Original Image')
Image_org = getframe(gcf);
file = fullfile(folderName, filePath);
imwrite(Image_org.cdata, file);

%convert the image to a double matrix having double values corresponding to
%the pixels in the images after grayscaling it
im_gray =im2double(rgb2gray(im)); 
%size(im_gray)
imshow(im_gray) 

title('GrayScale Image')
Image_new = getframe(gcf);
grayscaleFileName = strcat(fName, '_grayscaled', ext);
imwrite(Image_new.cdata, fullfile(folderName, grayscaleFileName));

[row column] = size(im_gray);
im_mean = mean(im_gray);  
meanNew = repmat(im_mean,row,1);
mean_matrix = im_gray - meanNew;
cov_matrix= cov(mean_matrix);  
[V, D] = eig(cov_matrix);
V_trans = transpose(V);
mean_matrix_trans = transpose(mean_matrix); 
FinalData = V_trans * mean_matrix_trans; 
PCs=input('Enter number of Principal components required -  ');
PCs = column - PCs;                                                        
Reduced_V = V;                                                        


%Selecting the PCs to make a Reduced matrix
for i = 1:PCs                                                        
  Reduced_V(:,1) =[];
end

Y=Reduced_V'* mean_matrix_trans;                                       
Compressed_Data=Reduced_V*Y;                                          
Compressed_Data = Compressed_Data' + meanNew;
OriginalData_trans = inv(V_trans) * FinalData;                        
Reconstructed_image = transpose(OriginalData_trans) + meanNew;          

imshow(Compressed_Data)

%save the compressed image to the folder
title("Compressed Image")
Image = getframe(gcf);
compressedFileName = strcat(fName, '_compressed', ext);
imwrite(Image.cdata, fullfile(folderName, compressedFileName));

%save the reconstructed image to the folder
imshow(Reconstructed_image)
title("Reconstructed Image")
Image = getframe(gcf);
reconstructedFileName = strcat(fName, '_reconstructed', ext);
imwrite(Image.cdata, fullfile(folderName, reconstructedFileName));

%size calculation
original=dir(filePath);
size_original = original.bytes

grayscale=dir(fullfile(folderName, grayscaleFileName));
size_gray=grayscale.bytes

comp=dir(fullfile(folderName, compressedFileName));
size_compressed = comp.bytes

res=dir(fullfile(folderName, reconstructedFileName));
size_reconstructed = res.bytes

Compression_ratio = size_original/size_compressed;
Compression_ratio

img1 =double(Compressed_Data);
img2 =double(im_gray);
%size(img1)
%size(img2)

mse = sum((img1(:)-img2(:)).^2) / prod(size(img1))
%mse=immse(img1,img2)
psnr = 10*log10(255*255/mse)
