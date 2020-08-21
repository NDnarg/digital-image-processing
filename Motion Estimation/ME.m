close all;
clc;

f1=imread('foreman_yuv_150.png');
f2=imread('foreman_yuv_151.png');
% load 2 frames;
F0 = 149; nf=2; 
for k=1:nf
   f{k} = imread(sprintf('foreman_yuv_%03d.png', F0+k)); 
end
% color conversion: RGB to YUV
A = [ 0.299 0.587 0.114; -0.14713 -0.28886 0.436; 0.615 -0.51499 -0.10001];
[h, w, kcolor]=size(f{1}); rgb = zeros(3,1); y1=zeros(h, w); u1=zeros(h,w); v1=zeros(h,w);
for j=1:h
    for k=1:w
        rgb(1) = f{1}(j, k, 1); rgb(2) = f{1}(j, k, 2); rgb(3) = f{1}(j, k, 3);
        yuv = (A*rgb);
        y1(j,k)=yuv(1); u1(j,k)=yuv(2); v1(j,k)=yuv(3); 
    end
end
figure(1); colormap('gray');
subplot(2,2,1); imagesc(y1); title('y'); 
subplot(2,2,2); imagesc(u1); title('u');
subplot(2,2,3); imagesc(v1); title('v'); 
subplot(2,2,4); hold on; grid on; 
[H1,V1]=hist(y1(:), 32); [H2,V2]=hist(u1(:), 32); [H3,V3]=hist(v1(:), 32);
H1=H1/sum(H1); H2=H2/sum(H2); H3=H3/sum(H3);
plot(V1, H1, '.-r'); plot(V2, H2, '.-b'); plot(V3, H3, '.-k'); 
legend(sprintf('y: %1.2f bits',getEntropy(H1)),  sprintf('u: %1.2f bits',getEntropy(H2)),  sprintf('v: %1.2f bits',getEntropy(H3)));

% load 2 frames in y{}
f0 = 149; nf=2; 
for k=1:nf
   im = imread(sprintf('foreman_yuv_%03d.png', f0+k)); 
   y{k} = fix(rgb2gray(im)); 
end
% motion comp between f1, f2
[im_h, im_w]=size(y{2}); 
bh = 8; bw = 8; 
% motion comp current frame
opt.range = 8; opt.pel = 1;
res_im = zeros(im_h,im_w);
for j=1:fix(im_h/bh)
    for k=1:fix(im_w/bw)
        % for block [j, k]
        x0 = (k-1)*bw; y0=(j-1)*bh; 
        blk = y{2}(y0+1:y0+bh, x0+1:x0+bw);
        [mv, res]=getBlkMotion(blk, x0+1, y0+1, f{1}, opt);
        fprintf('\n blk(%d, %d): mv=[%d %d], res=%1.2f', j, k, mv.x, mv.y, mean(res(:)));
        % residual image
        res_im(y0+1:y0+bh, x0+1:x0+bw) = res;
        % mv plot
        mv_plot.x(j,k) = x0+1; mv_plot.y(j,k) = y0 +1; 
        mv_plot.u(j,k) = mv.x; mv_plot.v(j,k) = mv.y;         
        %prediction image
        pf(y0+1:y0+bh, x0+1:x0+bw)=res+blk;
    end
end

figure(2); colormap('gray');
[h0, v0]=hist(single(y{2}(:)), 30); h0=h0/sum(h0); % original image entropy
[h1, v1]=hist(single(res_im(:)), 30); h1=h1/sum(h1); % predicted residual image entropy
[h2, v2]=hist(abs(single(y{2}-y{1})), 30);  h2=h2/sum(h2);
subplot(2,2,1); imagesc(y{2}); title('current frame'); 
subplot(2,2,2); imagesc(pf);title('prediction frame');
subplot(2,2,3); imagesc(abs(double(y{2}-y{1}))); title('current frame-reference frame');
subplot(2,2,4); imagesc(res_im); title('motion residual'); 


figure(3); imagesc(y{2}); hold on; grid on; colormap('gray');
quiver(mv_plot.x(:),mv_plot.y(:),mv_plot.u(:),mv_plot.v(:), '-r'); 
title('mv plots');

figure(4); hold on; grid on;
plot(v0, h0, '.-r'); plot(v1, h1, '.-b'); plot(v2, h2, '.-k');
title('compression from motion estimation');
legend(sprintf('original: %1.2f bits', getEntropy(h0)), sprintf('motion residual: %1.2f bits',getEntropy(h1)), sprintf('direct diff: 0.8581 bits', getEntropy(h2)));


