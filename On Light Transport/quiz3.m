clear all;
myFolder = 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene1';
myFolder2= 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene2';
myFolder3= 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene3';
[imageArray,imageArray2,imageArray3]=imagereader(myFolder,myFolder2,myFolder3);

for i=1:28
gimageArray(:,:,i)=rgb2gray(imageArray3(:,:,:,i));
end
maximage=zeros(964,1288,3);
temp=zeros(964,1288);
for(i=1:964)
    for(j=1:1288)
            for(g=3:28)
                if(gimageArray(i,j,g)>=temp(i,j))
                    maximage(i,j,1)=imageArray3(i,j,1,g);
                    maximage(i,j,2)=imageArray3(i,j,2,g);
                    maximage(i,j,3)=imageArray3(i,j,3,g);
                    temp(i,j)=gimageArray(i,j,g);
                end
            end
            
        
    end
end

minimage=uint8(255*ones(964,1288,3));
temp2=(255*ones(964,1288));
for(i=1:964)
    for(j=1:1288)
            for(g=3:28)
                if(gimageArray(i,j,g)<=temp2(i,j))
                    minimage(i,j,1)=imageArray3(i,j,1,g);
                    minimage(i,j,2)=imageArray3(i,j,2,g);
                    minimage(i,j,3)=imageArray3(i,j,3,g);
                    temp2(i,j)=gimageArray(i,j,g);
                    
                end
            end
            
        
    end
end


Ldirect=(abs((double(minimage)-double(maximage))));
Lglobal=uint8(imageArray3(:,:,:,2))- uint8(Ldirect);
imshow(uint8(Ldirect));

figure;
imshow(uint8(Lglobal));
















function [imageArray,imageArray2,imageArray3] = imagereader(myFolder,myFolder2,myFolder3)
filePattern = fullfile(myFolder, '*.PNG');
jpegFiles = dir(filePattern);
for k = 1:length(jpegFiles)
  baseFileName = jpegFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  imageArray(:,:,:,k) = imread(fullFileName);
end
filePattern = fullfile(myFolder2, '*.PNG');
jpegFiles = dir(filePattern);
for k = 1:length(jpegFiles)
  baseFileName = jpegFiles(k).name;
  fullFileName = fullfile(myFolder2, baseFileName);
  imageArray2(:,:,:,k) = imread(fullFileName);
end
filePattern = fullfile(myFolder3, '*.PNG');
jpegFiles = dir(filePattern);
for k = 1:length(jpegFiles)
  baseFileName = jpegFiles(k).name;
  fullFileName = fullfile(myFolder3, baseFileName);
  imageArray3(:,:,:,k) = imread(fullFileName);
end
end
