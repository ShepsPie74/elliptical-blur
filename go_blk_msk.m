
clc;
clear;
close all;

[msk_blk_dcts] = get_dct_blur_weights(16)

pos = 1;
for r = 1:5
  for c = 1:10
    subplot(5, 10, pos); imagesc(msk_blk_dcts{pos});
    pos = pos + 1;
  end
end


% for idx = 1:length(msk_blk_dcts)
%   imagesc(msk_blk_dcts{idx});
%   pause;
% end


return


blk_size = 16;
m = 2*blk_size+1;

as = logspace(-1, 0, 5)

for idx = 1:length(as)
  a = as(idx)  
  res = exp(-0.5*(([0:m-1]'-(m-1)/2)*a).^2);
  res_clip = res(blk_size+1:end-1);
  res_2d = res_clip * res_clip';
  res_2d(1:8, 1:8)
  imagesc(res_2d);
  pause;
end

return


for rad = 1:0.5:5
  
  rad
  msk_blk_dct = ones(blk_size, blk_size);
  for rb = 1:blk_size
    for cb = 1:blk_size
      if (sqrt(rb^2 + cb^2) >= rad)
        msk_blk_dct(rb, cb) = 0;
      end
    end
  end
  
  msk_blk_dct
  
end