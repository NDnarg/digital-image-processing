close all;
clc;
im=imread('lena.png');
im=rgb2gray(im);
im=double(im);
f1=[1/3 1/3 0
    1/3 0 0
    0 0 0];
q=4;
[h,w]=size(im);

res1=double(im)-double(imfilter(im,f1));
res1(1,:)=0;res1(:,1)=0;
res=fix(res1/q);r0=min(res(:));r1=max(res(:));
fprintf('\n res min=%d max=%d',r0,r1);
figure(1);colormap('gray');
subplot(2,2,1);imagesc(im);title('im');
subplot(2,2,2);imagesc(res1);title('res');
[h1,v1]=hist(im(:),[0:255]);h1=h1/sum(h1);
[h2,v2]=hist(res(:),[r0:1:r1]);h2=h2/sum(h2);
    
subplot(2,2,3);plot(h1,'.-b');hold on;grid on;title(sprintf('im entropy=%1.2f',getEntropy(h1)));
subplot(2,2,4);plot(h2,'.-k');hold on;grid on;title(sprintf('im entropy(q=%d)=%1.2f',q,getEntropy(h2)));
return;