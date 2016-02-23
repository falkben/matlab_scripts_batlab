%function compress_video(fname,deleteOrig)
function compress_video(fname,deleteOrig,mv_file,mv_dir)

[~, name] = system('hostname');
if strcmp(name(1:end-1),'fuscination')
  videotoolloc='C';
else
  videotoolloc='F';
end

% system(['C:\video_tools\ffmpeg_64\bin\ffmpeg.exe -y -i "' fname ...
%   '" -c:v libxvid -q:v 4 "' fname(1:end-3) 'mkv"']);
[status,~]=system([videotoolloc ':\video_tools\ffmpeg_64\bin\ffmpeg.exe -y -i "' fname ...
  '" -pix_fmt yuv420p -c:v libx264 -crf 22 "' fname(1:end-3) 'mp4"']);
if status~=0
  disp('something went wrong during compression')
end
if nargin>2 && mv_file
  if nargin>3 && ~isempty(mv_dir)
    movefile([fname(1:end-3) 'mp4'],mv_dir);
  else
    movefile([fname(1:end-3) 'mp4'],pwd);
  end
end
if status==0 && nargin > 1 && deleteOrig
  delete(fname)
end