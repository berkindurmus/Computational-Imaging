clear all;
both=imread('IMG_3378.jpg');
left=imread('IMG_3379.jpg');
right=imread('IMG_3380.jpg');
both=both(1:2064,1:4031,:);
left=left(1:2064,1:4031,:);
right=right(1:2064,1:4031,:);
newimage=zeros(2064,4031,3);
newimage(:,:,3)=left(:,:,1);

newimage(:,:,1)=right(:,:,2);
syntboth=uint8(left)+uint8(right);
diff=(uint16(abs(uint16(syntboth)-uint16(both))));
maxdif1=max(max(diff(:,:,1)));
maxdif2=max(max(diff(:,:,2)));
maxdif3=max(max(diff(:,:,3)));

figure
imshow(diff);
diff2(:,:,1)=(double(diff(:,:,1))./double(maxdif1));
diff2(:,:,2)=(double(diff(:,:,2))./double(maxdif2));
diff2(:,:,3)=(double(diff(:,:,3))./double(maxdif3));
figure;
 imshow((diff2));

