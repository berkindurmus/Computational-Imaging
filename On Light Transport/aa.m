clear all;
myFolder = 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene1';
myFolder2= 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene2';
myFolder3= 'C:\Users\Berkin\Desktop\comp quiz3\quiz3_scenes\scene3';
[imageArray,imageArray2,imageArray3]=imagereader(myFolder,myFolder2,myFolder3);


maximage=zeros(964,1288,3);
temp=zeros(964,1288,3);
for(i=1:964)
    for(j=1:1288)
        
            for(g=3:28)
                if(0.21*imageArray(i,j,1,g)+0.72*imageArray(i,j,2,g)+0.07*imageArray(i,j,3,g)>=0.21*temp(i,j,1)+0.72*temp(i,j,2)+0.07*temp(i,j,3))
                   
                    temp(i,j,1)=imageArray(i,j,1,g);
                    temp(i,j,2)=imageArray(i,j,2,g);
                    temp(i,j,3)=imageArray(i,j,3,g);
                end
            end
            
        
    end
end

minimage=uint8(255*ones(964,1288,3));
temp2=(255*ones(964,1288,3));
for(i=1:964)
    for(j=1:1288)
        
            for(g=3:28)
                if(0.21*imageArray(i,j,1,g)+0.72*imageArray(i,j,2,g)+0.07*imageArray(i,j,3,g)<=0.21*temp2(i,j,1)+0.72*temp2(i,j,2)+0.07*temp2(i,j,3))
                   
                    temp2(i,j,1)=imageArray(i,j,1,g);
                    temp2(i,j,2)=imageArray(i,j,2,g);
                    temp2(i,j,3)=imageArray(i,j,3,g);
                end
            end
            
        
    end
end
b(:,:,:)=imageArray(:,:,:,1)./imageArray(:,:,:,2);
Lglobal(:,:,1)=uint8((2.*uint8(temp2(:,:,1))-2.*uint8((b(:,:,1)).*uint8(temp(:,:,1))))./uint8((1-(b(:,:,1)).^2)));
Lglobal(:,:,2)=uint8((2.*uint8(temp2(:,:,2))-2.*(uint8(b(:,:,2)).*uint8(temp(:,:,2))))./uint8(1-(b(:,:,2)).^2));
Lglobal(:,:,3)=uint8((2.*uint8(temp2(:,:,3))-2.*(uint8(b(:,:,3)).*uint8(temp(:,:,1))))./uint8(1-(b(:,:,3)) .^2));
Ldirect(:,:,1)=(uint8(temp(:,:,1)))-uint8(0.5.*uint8(Lglobal(:,:,1)).*uint8(1+b(:,:,1)));
Ldirect(:,:,2)=(uint8(temp(:,:,2)))-uint8(0.5.*uint8(Lglobal(:,:,2)).*uint8(1+b(:,:,2)));
Ldirect(:,:,3)=(uint8(temp(:,:,3)))-uint8(0.5.*uint8(Lglobal(:,:,3)).*uint8(1+b(:,:,3)));
imshow(uint8(Ldirect));
title('Direct')
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
