clear;
close all;

fs=250000;
slowdown=15;
new_fs=fs/slowdown;
vid_frate=30;

res_width=600;
res_height=200;

%load the signal.mat file
% data=signal;

%load wav file
[fn,pn] = uigetfile('*.wav','load wav file');
if isequal(pn,0)
  return
end
data = audioread(fn);

data=data-mean(data);

figure(2)
spectrogram(data( 1 : round((length(data)/10)) ),256,250,256,fs,'yaxis')
[mincc, maxcc]=caxis;
close(2)

sound_duration=length(data)/fs;
new_dur=sound_duration*slowdown;
frames = 1:round(new_dur*vid_frate);

samp_step_size=round( fs*sound_duration / (vid_frate*new_dur) );
samp=1 : samp_step_size : length(data);

% soundsc(data,fs/slowdown)

writerObj = VideoWriter([pn '\' fn(1:end-3) 'avi'],'uncompressed avi');
writerObj.FrameRate = vid_frate;
% writerObj.Quality = 90;
open(writerObj);

figure(1); clf;
set(gcf,'position',[10 10 res_width res_height],'color','black')
axes('position', [0 0 1 1])
for fr=frames
  samps=samp(fr)-.2*fs:samp(fr);
  
  if samps(end)>length(data)
    DD=[data(samps(1):length(data)); zeros(samps(end)-length(data)+1,1)];
  elseif samps(1)<1
    DD=[zeros(abs(samps(1)),1) ; data(1:samps(end))];
  else
    DD=data(samps);
  end
  
%   [S,F,T,P] = spectrogram(data(samps),256,250,256,fs);
  [S,F,T,P] = spectrogram(DD,256,250,256,fs);
  imagesc(T,F,10*log10(P));
  set(gca,'YDir','normal','xtick',[],'ytick',[]);
  caxis([mincc+75 maxcc]);
  colormap hot
  
%   drawnow;
  frame = getframe(gca);
  writeVideo(writerObj,frame);
end

close(writerObj);

filename=[pn '\' fn(1:end-3) 'wav'];
audiowrite(filename,data/max(abs(data)),round(new_fs));

compress_video([pn '\' fn(1:end-3) 'avi'],1)