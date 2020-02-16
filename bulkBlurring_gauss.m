cclc
% close all
clear all

vid_secs = ; % approximate duration of the video
vid_dir = ''; % directory of your video

blk_size = 16;

pos = [  ]; % Enter the position, and dimensions of the desired elliptical Region of Interest. To get these values, please refer to the notepad.

noise_levels = 50; % makes 50 video files with 50 different noise levels.

s_vals = [
  9.8363
  9.5045
  9.0903
  8.6069
  8.0856
  7.5555
  7.0315
  6.5344
  6.0641
  5.6274
  5.2188
  4.8392
  4.4846
  4.1542
  3.8463
  3.5591
  3.2916
  3.0424
  2.8122
  2.5992
  2.4012
  2.2187
  2.0497
  1.8940
  1.7502
  1.6172
  1.4941
  1.3802
  1.2750
  1.1773
  1.0869
  1.0034
  0.9261
  0.8551
  0.7904
  0.7320
  0.6803
  0.6353
  0.5966
  0.5636
  0.5353
  0.5109
  0.4898
  0.4710
  0.4546
  0.4400
  0.4269
  0.4151
  0.4046
  0.3951
  ]; % values of 50 varying strengths of videos. Produces lvl 50 to lvl 1

num_lvls = length(s_vals);
h_blrs = cell(num_lvls, 1);
for idx = 1:num_lvls
  h_blrs{idx} = fspecial('gaussian', 45, s_vals(idx));
end

vid_idxs = []; % useful if a there are a stream of videos present in the directory. Eg. 1.mp4, 2.mp4 and so on
% would strongly recommend RENAMING the mp4 video file to a number, like in the above example.

for vid_idx_pos = 1:length(vid_idxs)
  
  vid_idx = vid_idxs(vid_idx_pos)
  ipVideoFile1 = VideoReader([vid_dir num2str(vid_idx) '.mp4']);
  
  src_img_rgb = readFrame(ipVideoFile1);
  num_rows = size(src_img_rgb, 1);
  num_cols = size(src_img_rgb, 2);
  num_cols = floor(num_cols/blk_size)*blk_size;
  num_rows = floor(num_rows/blk_size)*blk_size;
  src_img_rgb = src_img_rgb(1:num_rows, 1:num_cols, :);
  
%   dst_img_rgb = imfilter(src_img_rgb, h_blrs{1}, 'symmetric');
%   figure; imshow(dst_img_rgb);
%   
%   src_img_gry = double(rgb2gray(src_img_rgb));
%   dst_img_gry = double(rgb2gray(dst_img_rgb));
%   mse_val_blr = mean2((dst_img_gry - src_img_gry).^2)
%   psnr_val_blr = 10*log10(255^2 / mse_val_blr)
% 
%   return  
  
  p = pos(vid_idx, :);
  xo = round(p(1) + 0.5*p(3));
  yo = round(p(2) + 0.5*p(4));
  
  h = imshow(src_img_rgb);
  e = concEllipse(p, 3, 0.5);
%   continue
  % return
  
  BW_3 = double( ~createMask( e(1), h ) );
  BW_2 = double( ~createMask( e(2), h ) );
  BW_1 = double( ~createMask( e(3), h ) );
  BW_0 = double( createMask( e(3), h ) );
  BW_1 = BW_1 - BW_2;
  BW_2 = BW_2 - BW_3;
  
  h = fspecial('gaussian', 51, 10);
%   figure; mesh(h);
%   return
  BW_0 = imfilter(BW_0, h, 'symmetric');
  BW_1 = imfilter(BW_1, h, 'symmetric');
  BW_2 = imfilter(BW_2, h, 'symmetric');
  BW_3 = imfilter(BW_3, h, 'symmetric');    
%   figure(100); imshow(BW_1, []);
%   figure(200); imshow(BW_2, []);
%   figure(300); imshow(BW_3, []);
%   return
    
  for lvl_idx = 1:noise_levels
    
    msk_idx_3 = lvl_idx;
    if (lvl_idx <= 30)
      msk_idx_1 = round(lvl_idx/6 + 25);
    else
      msk_idx_1 = lvl_idx;
    end
    msk_idx_2 = round(mean([msk_idx_1, msk_idx_3]));
    [msk_idx_3 msk_idx_2 msk_idx_1]
    
    op_fname = ...
      [vid_dir 'Gauss\' num2str(vid_idx) '.gauss_blr.' sprintf('%0.1f', 51-lvl_idx)]
    
    opVideoFile1 = VideoWriter(op_fname, 'MPEG-4');
    opVideoFile1.Quality = 95;
    opVideoFile1.FrameRate = 30;
    
    open(opVideoFile1);
    try
      ipVideoFile1.CurrentTime = 0;
      while hasFrame(ipVideoFile1)
        if (ipVideoFile1.CurrentTime > vid_secs)
          break;
        end
        
        disp('Current time index: ');
        disp(ipVideoFile1.CurrentTime);
        
        src_img_rgb = readFrame(ipVideoFile1);
        src_img_rgb = double(src_img_rgb(1:num_rows, 1:num_cols, :));
        
        src_img_rgb_3 = ...
          imfilter(src_img_rgb, h_blrs{msk_idx_3}, 'symmetric');
        src_img_rgb_2 = ...
          imfilter(src_img_rgb, h_blrs{msk_idx_2}, 'symmetric');
        src_img_rgb_1 = ...
          imfilter(src_img_rgb, h_blrs{msk_idx_1}, 'symmetric');
        
        dst_img_rgb = zeros(num_rows, num_cols, 3);
        dst_img_rgb(:, :, 1) = ...
          BW_0 .* src_img_rgb(:, :, 1) + ...
          BW_1 .* src_img_rgb_1(:, :, 1) + ...
          BW_2 .* src_img_rgb_2(:, :, 1) + ...
          BW_3 .* src_img_rgb_3(:, :, 1);
        dst_img_rgb(:, :, 2) = ...
          BW_0 .* src_img_rgb(:, :, 2) + ...
          BW_1 .* src_img_rgb_1(:, :, 2) + ...
          BW_2 .* src_img_rgb_2(:, :, 2) + ...
          BW_3 .* src_img_rgb_3(:, :, 2);
        dst_img_rgb(:, :, 3) = ...
          BW_0 .* src_img_rgb(:, :, 3) + ...
          BW_1 .* src_img_rgb_1(:, :, 3) + ...
          BW_2 .* src_img_rgb_2(:, :, 3) + ...
          BW_3 .* src_img_rgb_3(:, :, 3);
        
        dst_img_rgb = uint8(dst_img_rgb);
        
%         src_img_gry = double(rgb2gray(uint8(src_img_rgb(:, 1:600, :))));
%         dst_img_gry = double(rgb2gray(dst_img_rgb(:, 1:600, :)));
%         mse_val = mean2((dst_img_gry - src_img_gry).^2)
%         psnr_val = 10*log10(255^2 / mse_val)
        
%         alpha = 0.7;
%         dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 1) = ...
%           alpha*255 + (1-alpha)*dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 1);
%         dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 2) = ...
%           (1-alpha)*dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 1);
%         dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 3) = ...
%           (1-alpha)*dst_img_rgb(yo-16:yo+16, xo-1:xo+1, 1);
%         dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 1) = ...
%           alpha*255 + (1-alpha)*dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 1);
%         dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 2) = ...
%           (1-alpha)*dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 1);
%         dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 3) = ...
%           (1-alpha)*dst_img_rgb(yo-1:yo+1, xo-16:xo+16, 1);
        
%         figure(2); imshow(dst_img_rgb);
%         drawnow update;
%         return;
        
        writeVideo(opVideoFile1, dst_img_rgb);
      end
      
      close(opVideoFile1);
      
    catch err
      close(opVideoFile1);
      rethrow(err);
    end
    
  end % for lvl_idx
  
end % for vid_idx
