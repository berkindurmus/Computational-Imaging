clear all;
load('labels2.mat')
load('v.mat')
load('vvv.mat')

%%
%v = framereader('30fpsvideo.MOV');
%vvv = VideoReader('30fpsvideo.MOV');
vcolor=framereadercolor('30fpsvideo.MOV');
%%
xofobject=gTruth.LabelData.Nutella{1}(1);
yofobject=gTruth.LabelData.Nutella{1}(2);
widthofobject=gTruth.LabelData.Nutella{1}(3);
heightofobject=gTruth.LabelData.Nutella{1}(4);
xofwindow=gTruth.LabelData.NutellaWindow{1}(1);
yofwindow=gTruth.LabelData.NutellaWindow{1}(2);
widthofwindow=gTruth.LabelData.NutellaWindow{1}(3);
heightofwindow=gTruth.LabelData.NutellaWindow{1}(4);

frame1=v(:,:,1);


object=frame1(yofobject:yofobject+heightofobject-1,xofobject:xofobject+widthofobject-1);
%windowofobject=frame1(yofwindow:yofwindow+heightofwindow-1,xofwindow:xofwindow+widthofwindow-1);
%crosscor=normxcorr2(object,windowofobject);
%imshow(crosscor,[])
% %% WITH WINDOW
% shiftx=0;
% shifty=0;
% for(i=1:350)
% frame1=v(:,:,i);
% xp=zeros(1);
% yp=zeros(1);
% crosscor=[];
% windowofobject=frame1(yofwindow+shiftx:yofwindow+heightofwindow-1+shiftx,xofwindow+shifty:xofwindow+widthofwindow-1+shifty);
% 
% %imshow(windowofobject);
% %figure;
% crosscor=normxcorr2(object,windowofobject);
% [xp,yp]= find(crosscor==max(crosscor(:)));
% yoffSet(i) = yp-size(object,1);
% xoffSet(i) = xp-size(object,2);
% if(i~=1)
%  shiftx=xoffSet(i-1)-xoffSet(i);
%  shifty=yoffSet(i-1)-yoffSet(i);
%  if(abs(shiftx)>30)
%      shiftx=0;
%  end
%  if(abs(shifty)>30)
%  shifty=0;
%  end
%  
%  ssx(i)=shiftx;
%  ssy(i)=shifty;
% end
% end


%%
for i=1:350
frame1=v(:,:,i);
xp=zeros(1);
yp=zeros(1);

crosscor=normxcorr2(object,frame1);
if i ==1
    figure;
    foto=crosscor;
    imshow(crosscor,[]);
    figure;
     surface(crosscor)
     figure;
end
%imshow(crosscor,[]);
[xp,yp]= find(crosscor==max(crosscor(:)));
normvector(i)=crosscor(xp,yp);
yoffSet(i) = yp-size(object,1);
xoffSet(i) = xp-size(object,2);
end

%% Shift Calculation
% for(i=1:350)
%     frame1=v(:,:,i);
%     windowofobject=frame1(yofwindow:yofwindow+heightofwindow-1,xofwindow:xofwindow+widthofwindow-1);
% crosscor=normxcorr2(object,windowofobject);
%     
% [x(i),y(i)]= find(crosscor==max(crosscor(:)));;
% end
%%
framenumber=100;
gg=normvector;
normvector=normvector(1:framenumber)./sum(normvector(1:framenumber));
temp=normvector(1)*vcolor(:,:,:,1);

for i=2:framenumber
aa=(imtranslate(vcolor(:,:,:,i),[yoffSet(1)-yoffSet(i),xoffSet(1)-xoffSet(i)]));
%temp=((temp)+normvector(i)*(aa));
temp=imadd(double(temp),normvector(i)*double(aa));
%imshow(uint8(temp./i))
%figure
%image=imadd(temp,image);
end
imshow(uint8(temp))

%%

% temm=v(:,:,1);
% for i=1:30
% temm=double(temm)+double(v(:,:,1));
% temm=temm./2;
% imshow(uint8(temm))
% figure
% end
%%
function f = framereader(n)
    vvv = VideoReader(n);
    video = read(vvv);
    
    framelength=int64((vvv.Framerate)*(vvv.Duration));
    for i=1:framelength
        videogray(:,:,i)=rgb2gray(video(:,:,:,i));
    end
    f=videogray;
    
end
function g= framereadercolor(n)
vvv = VideoReader(n);
    video = read(vvv);
    
   
    g=video;
    
end