%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getBlkMotion()
%   block based motion estimation
% input:
%   blk - m x m blocks
%   x0, y0 - blk location in current frame
%   im  - hxw a frame
%   opt.pel = 1, 0.5 0.25: pel steps
%   opt.range = 12; 
% output:
%   mv - motion vector
%   res - residual.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [mv, res]=getBlkMotion(blk, x0, y0 im, opt)
function [mv, res]=getBlkMotion(blk, x0 , y0, im, opt)
dbg=0;
if dbg
    % load 6 frames in y
    f0 = 150; nf=3; 
    for k=1:nf
        f = imread(sprintf('data/png/foreman_yuv_%03d.png', f0+k)); 
        im{k} = rgb2gray(f); 
    end
    x0=160; y0=70; blk = im{2}(y0:y0+7, x0:x0+11); 
    opt.pel = 1; opt.range = 16; 
    im = im{1};
end

% fractional pel
[ht, wid]=size(im); [bh, bw]=size(blk); 

% interpolate
if opt.pel == 0.5
    blk = bilinearInterpolation(blk, 2*[bh, bh]);
    im = bilinearInterpolation(im, 2*[ht, wid]);
    x0=x0*2; y0=y0*2; 
elseif opt.pel == 0.25
    blk = bilinearInterpolation(blk, 4*[bh, bh]);
    im = bilinearInterpolation(im, 4*[ht, wid]);
    x0=x0*4; y0=y0*4;
else % int pel
    fprintf('\n int pel motion est...');
end
    

% exhaustive search
[ht, wid]=size(im); [bh, bw]=size(blk); 
min_df = inf;  mv.x=0; mv.y=0;
j=0; k=0; mad = inf*ones(2*opt.range+1, 2*opt.range+1); mad_min=inf; 
for y_offs=-opt.range:opt.range
    j = j+1; k=0;
    for x_offs = -opt.range:opt.range   
        k = k+1;
        if y0+y_offs > 0 && y0+y_offs <= (ht-bh) && x0+x_offs > 0 && x0+x_offs <= (wid-bw)
            blk_res = abs(im(y0+y_offs:y0+y_offs+bh-1, x0+x_offs: x0+x_offs+bw-1) - blk);
            mad(j,k) = mean(blk_res(:)); 
            mvs(j,k).x = x_offs; mvs(j,k).y = y_offs;
            if mad(j,k) < mad_min
                mad_min = mad(j,k); 
                mv = mvs(j,k); 
                res = blk_res; 
            end
        else
            mad(j,k) = inf; 
            mvs(j,k).x = x_offs; mvs(j,k).y = y_offs;
        end        
        if (dbg) 
            fprintf('\n mad(%d, %d)=%1.2f', y_offs, x_offs, mad(j,k));               
        end
    end
    
end

% best match 
% [min_mad, indx]=min(mad(:));
% mv = mvs(indx(1));
    

if (dbg)
    figure(31);colormap('gray'); 
    subplot(2,2,1); imagesc(blk); title('block'); 
    subplot(2,2,2); grid on; hold on; surf(mad); xlabel('mv.x'); ylabel('mv.y'); zlabel('mad'); 
    subplot(2,2,3); plot(sort(mad(:)), '-'); grid on; hold on;  title('mad distribution'); 
    subplot(2,2,4); imagesc(res); title('block res');

end

return;