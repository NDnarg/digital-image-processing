clear all;
close all;
I=imread('lena.png');
subplot(5,2,1);imshow(I);title('Original Image');
g=rgb2gray(I);
subplot(5,2,3);imshow(g);title('Gray Image');
subplot(5,2,4);imhist(g);title('Gray Histogram');
R=I(:,:,1);
G=I(:,:,2);
B=I(:,:,3);

[row,col]=size(g);
blackImage=uint8(zeros(row,col));

nR=cat(3,R,blackImage,blackImage);
subplot(5,2,5);imshow(nR);title('Red Image');
subplot(5,2,6);imhist(R);title('Red Histogram');

nG=cat(3,blackImage,G,blackImage);
subplot(5,2,7);imshow(nG);title('Green Image');
subplot(5,2,8);imhist(G);title('Green Histogram');

nB=cat(3,blackImage,blackImage,B);
subplot(5,2,9);imshow(nB);title('Blue Image');
subplot(5,2,10);imhist(B);title('Blue Histogram');

g=double(g); 
sum=0;
for i=1:row
    for j=1:col
        sum=sum+g(i,j);
    end
end
 
%均值
E=sum/(row*col)
 
%求方差
s=0;
for x=1:row
    for y=1:col
        s=s+(g(x,y)-E)^2;
end
end
D=s/(row*col)
 
%求信息熵
temp=zeros(1,256);
for m=1:row;
    for n=1:col;
        if g(m,n)==0; 
           i=1; 
        else
           i=g(m,n);
        end
    temp(i)=temp(i)+1; 
    end
end

temp=temp/(row*col);
entropy=0;
for i=1:length(temp) 
    if temp(i)==0; 
    else 
       entropy=entropy-temp(i)*log2(temp(i));
    end
end