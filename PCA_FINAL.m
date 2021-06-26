condition = true;
while condition   % loop that enables trying again (simlar to do-while loop)
    clear;
    close all;
    clc;
    
    filePath = input("Enter the name of image : ");
    im = imread(filePath);
    
    %to get the extension of file so that pictures can be saved in the same
    %extension
    [~,fName,ext] = fileparts(which(filePath));
    
    %to reduce clutter, make a new folder as per the user's wish and store all the
    %related files there
    folderName = input("Enter the folder name you want to save the compressed images: ");
    mkdir(folderName);
    folderName_new = "temp";
    mkdir(folderName_new);
    
    
    %put the original image in a frame and put it to the new folder
    %(saving original image)
    imshow(im)
    title('Original Image')
    Image_org = getframe(gcf);
    file = fullfile(folderName, filePath);
    imwrite(Image_org.cdata, file);
    
    %convert the image to a double matrix having double values corresponding to
    %the pixels in the images after grayscaling it
    im_gray =im2double(rgb2gray(im));
    imshow(im_gray)
    
    %(saving original image)
    title('GrayScale Image')
    Image_new = getframe(gcf);
    grayscaleFileName = strcat(fName, '_grayscaled', ext);
    imwrite(Image_new.cdata, fullfile(folderName, grayscaleFileName));
    grayscale=dir(fullfile(folderName, grayscaleFileName));
    
    %finding covariance matrix and other required matrices
    size_gray=grayscale.bytes;
    [row column] = size(im_gray);
    im_mean = mean(im_gray);
    meanNew = repmat(im_mean,row,1);
    mean_matrix = im_gray - meanNew;
    cov_matrix= cov(mean_matrix);
    [V, D] = eig(cov_matrix);
    V_trans = transpose(V);
    mean_matrix_trans = transpose(mean_matrix);
    FinalData = V_trans * mean_matrix_trans;
    
    
    %INVERSE PCA TO RECONSTRUCT IMAGE WITH ALL PRINCIPAL COMPONENTS
    OriginalData_trans = inv(V_trans) * FinalData;
    Reconstructed_image = transpose(OriginalData_trans) + meanNew;
    %save the reconstructed image to the folder (INVERSE PCA OUTPUT)
    imshow(Reconstructed_image)
    title("Reconstructed Image")
    Image = getframe(gcf);
    reconstructedFileName = strcat(fName, '_reconstructed', ext);
    imwrite(Image.cdata, fullfile(folderName, reconstructedFileName));
    % END OF INVERSE PCA
    
    
    % GETTING THE SIZE OF MAXIMUM COMPRESSED IMAGE (MIN SIZE AFTER COMPRESSION)
    % BY MAKING PCS = COLUMN
    PCs = column;
    Reduced_V = V;
    %reducing dimension of eigen vector
    for i = 1:PCs
        Reduced_V(:,1) =[];
    end
    
    Y=Reduced_V'* mean_matrix_trans;
    Compressed_Data=Reduced_V*Y;
    Compressed_Data = Compressed_Data' + meanNew;
    
    %save the compressed image to the folder
    imshow(Compressed_Data)
    t="Compressed Image min size";
    title("Compressed Image")
    Image1 = getframe(gcf);
    min_compressedFileName = strcat(fName, t, ext);
    imwrite(Image1.cdata, fullfile(folderName_new, min_compressedFileName));
    comp1=dir(fullfile(folderName_new, min_compressedFileName));
    size_compressed_min = comp1.bytes;
    
    %END OF GETTING SIZE OF MAXIMUM COMPRESSED IMAGE
    
    
    
    % GETTING THE SIZE OF MINIMUM COMPRESSED IMAGE (MAX SIZE AFTER COMPRESSION)
    % BY MAKING PCS = 1
    PCs = 1;
    Reduced_V = V;
    %reducing dimension of eigen vector
    for i = 1:PCs
        Reduced_V(:,1) =[];
    end
    
    Y=Reduced_V'* mean_matrix_trans;
    Compressed_Data=Reduced_V*Y;
    Compressed_Data = Compressed_Data' + meanNew;
    
    %save the compressed image to the folder
    imshow(Compressed_Data)
    t="Compressed Image max size";
    title("Compressed Image")
    Image = getframe(gcf);
    max_compressedFileName = strcat(fName, t, ext);
    imwrite(Image.cdata, fullfile(folderName_new, max_compressedFileName));
    comp=dir(fullfile(folderName_new, max_compressedFileName));
    size_compressed_max = comp.bytes;
    
    %END OF GETTING SIZE OF MINIMUM COMPRESSED IMAGE
    
    
    
    %FOUND ALL THE ESSENTIAL DATA
    %STARTING OF REAL PROGRAM
    
    count=1;      %TO KEEP A TRACK OF THE EIGEN VECTOR WHILE SAVING COMPRESSED IMAGES , THIS NUMBER GETS ADDED TO THE NAME OF COMPRESSED FILE
    images=0;
    fprintf("============================================================================================")
    fprintf("\nMention the range in which you want your image to be compressed\n")
    fprintf("The range should be between %s bytes ",num2str(size_compressed_min));
    fprintf("and %s bytes",num2str(size_compressed_max));
    range1=input("\n\nEnter the lower limit of your preferred range (in bytes) - ");
    range2=input("Enter the higher limit of your preferred range (in bytes) - ");
    fprintf("\n============================================================================================\n")
    
    if(range2<=size_compressed_max&&range1>=size_compressed_min)  %CHECKING IF INPUT SIZE IS WITHIN THE BOUNDS
        fprintf("Processing, Please wait...")
        
        for i=1:column    % LOOP VARIABLE 'i' REPRESENTS THE NUMBER OF PC TAKEN AT EACH ITERATION
            PCs = column - i;
            Reduced_V = V;
            %REDUCING DIMENSION OF EIGEN VECTOR ACCORDING TO NUMBER OF PC TAKEN
            %IN THIS ITERATION
            for i = 1:PCs
                Reduced_V(:,1) =[];
            end
            
            Y=Reduced_V'* mean_matrix_trans;
            Compressed_Data=Reduced_V*Y;
            Compressed_Data = Compressed_Data' + meanNew;
            OriginalData_trans = inv(V_trans) * FinalData;
            Reconstructed_image = transpose(OriginalData_trans) + meanNew;
            
            %save the compressed image made out of 'i' PC to the folder
            imshow(Compressed_Data)
            t=strcat("Compressed Image ",num2str(count));
            title("Compressed Image")
            Image = getframe(gcf);
            compressedFileName = strcat(fName, t, ext);
            imwrite(Image.cdata, fullfile(folderName_new, compressedFileName));
            comp=dir(fullfile(folderName_new, compressedFileName));
            size_compressed = comp.bytes;
            
            %CHECKING IF THE SIZE OF COMPRESSED IMAGE IN THIS ITERATION IS WITHIN THE RANGE REQUESTED BY USER
            if(size_compressed>range1&&size_compressed<range2)
                fprintf("\nNo of PC: "+(column-i));
                
                images = images + 1;
                imshow(Compressed_Data)
                t=strcat("Compressed Image ",num2str(count));
                title("Compressed Image")
                Image = getframe(gcf);
                compressedFileName = strcat(fName, t, ext);
                imwrite(Image.cdata, fullfile(folderName, compressedFileName));
                comp=dir(fullfile(folderName, compressedFileName));
                size_compressed = comp.bytes;  %GETTING SIZE IN BYTES OF COMPRESSED IMAGE
                fprintf("\n\nSize compressed: "+size_compressed)
                
                %COMPRESSION RATIO CALCULATION
                original=dir(filePath);
                size_original = original.bytes;  %GETTING SIZE IN BYTES OF ORIGINAL IMAGE
                Compression_ratio = size_original/size_compressed;
                fprintf("\nCompression ratio: "+Compression_ratio)
                
                %MSE AND PSNR CALCULATIONS
                img1 =double(Compressed_Data);
                img2 =double(im_gray);
                mse = sum((img1(:)-img2(:)).^2) / prod(size(img1));
                fprintf("\nMSE: "+mse)
                
                psnr = 10*log10(255*255/mse);
                fprintf("\nPSNR: "+psnr)
                
                fprintf("\n=============================================================================================")
                
            else if(size_compressed>range2)
                    fprintf("\n\nTotal number of images generated: "+images)
                    rmdir(folderName_new, 's')
                    break;
                end
            end
            count=count+1;
        end
        
    else if(range1<size_compressed_min||range2>size_compressed_max)  %HANDLING WHEN RANGE INPUTTED BY USER IS NOT VALID
            fprintf("\nOops\nThis size "+range1+ " is out of bound \n");
        end
    end
    wish=input("\n\nDo you want to try again ? If yes press 1 -  ");
    condition=wish==1;     %UPDATION IN CONDITION OF TOP MOST WHILE LOOP( DO WHILE TO TRY AGAIN)
    if(~condition)
        fprintf("\n\n THANK YOU... RERUN THE PROGRAM INCASE YOU NEED TO TRY AGAIN\n")
    end
end
