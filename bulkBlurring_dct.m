clc
% close all
clear all

vid_secs = ; % approximate duration of the video
vid_dir = ''; % directory of your video

blk_size = 16;
half_blk_size = blk_size / 2;

noise_levels = 50; % makes 50 video files with 50 different noise levels

pos = [  ]; % Enter the position, and dimensions of the desired elliptical Region of Interest. To get these values, please refer to the notepad.

vid_idxs = []; % useful if a there are a stream of videos present in the directory. Eg. 1.mp4, 2.mp4 and so on
% would strongly recommend RENAMING the mp4 video file to a number, like in the above example.


for vid_idx_pos = 1:length(vid_idxs)
  
  vid_idx = vid_idxs(vid_idx_pos)
  ipVideoFile1 = VideoReader([vid_dir num2str(vid_idx) '.mp4']);
  
  src_img_rgb = readFrame(ipVideoFile1);
  num_rows = size(src_img_rgb, 1);
  num_cols = size(src_img_rgb, 2);90
  num_cols = floor(num_cols/blk_size)*blk_size;
  num_rows = floor(num_rows/blk_size)*blk_size;
  src_img_rgb = src_img_rgb(1:num_rows, 1:num_cols, :);
  
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
  BW_1 = BW_1 - BW_2;
  BW_2 = BW_2 - BW_3;
  % figure(100); imshow(BW_1, []);
  % figure(200); imshow(BW_2, []);
  % figure(300); imshow(BW_3, []);
  % return
  
  msk_blk_dct_0 = ones(blk_size, blk_size);
  [msk_blk_dcts] = get_dct_blur_weights(blk_size);
  
  % return
  
  for lvl_idx = 1: noise_levels
    
    msk_idx_3 = lvl_idx;
    if (lvl_idx <= 30)
      msk_idx_1 = round(lvl_idx/6 + 25);
    else
      msk_idx_1 = lvl_idx;
    end
    msk_idx_2 = round(mean([msk_idx_1, msk_idx_3]));
    [msk_idx_3 msk_idx_2 msk_idx_1]
    
    
    op_fname = ...
      [vid_dir 'DCT\' num2str(vid_idx) '.dct_blr.' sprintf('%0.1f', 51-lvl_idx)]
    
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
        src_img_rgb = src_img_rgb(1:num_rows, 1:num_cols, :);
        
        %     h = fspecial('gaussian', 21, 2);
        %     src_img_rgb = imfilter(src_img_rgb, h);
        
        src_img_ycbcr = rgb2ycbcr(src_img_rgb);
        dst_img_ycbcr = src_img_ycbcr;
                
        for r = 1:blk_size:num_rows
          rs = [r:r+blk_size-1];
          for c = 1:blk_size:num_cols
            cs = [c:c+blk_size-1];            
            if (BW_3(r+half_blk_size, c+half_blk_size) > 0)
              msk_blk_dct = msk_blk_dcts{msk_idx_3};
            elseif (BW_2(r+half_blk_size, c+half_blk_size) > 0)
              msk_blk_dct = msk_blk_dcts{msk_idx_2};
            elseif (BW_1(r+half_blk_size, c+half_blk_size) > 0)
              msk_blk_dct = msk_blk_dcts{msk_idx_1};
            else
              msk_blk_dct = msk_blk_dct_0;
            end
                       
            % compute the DCT
            src_blk_y_dct = dct2(src_img_ycbcr(rs, cs, 1));
            
            % blur in the DCT domain
            dst_blk_y_dct = src_blk_y_dct .* msk_blk_dct;
            
            % convert back to the pixel domain
            dst_img_ycbcr(rs, cs, 1) = idct2(dst_blk_y_dct);
          end
        end
        
        dst_img_rgb = ycbcr2rgb(uint8(dst_img_ycbcr));
        
        %       mse_val = mean2((double(dst_img_ycbcr(:, :, 1)) - ...
        %         double(src_img_ycbcr(:, :, 1))).^2)
        %       psnr_val = 10*log10(255^2 / mse_val)
        
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
%         break;
        
        writeVideo(opVideoFile1, dst_img_rgb);
      end
      
      close(opVideoFile1);
      
    catch err
      close(opVideoFile1);
      rethrow(err);
    end
    
  end % for lvl_idx
  
end % for vid_idx
