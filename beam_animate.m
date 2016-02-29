clear;

data_path='E:\Desktop\Ben_trial\';

fn={'rousettus_41'};
d2=1; %2d data only
gaussfitfcn=1; %0 to use normfit function of matlab
freqi=18;
save_movie=0;
diag=1;
vid_frate=50;



  
for tt=1:length(fn)
  if save_movie
    v=VideoWriter(['trial' fn{tt} '.avi'],'uncompressed avi');
    v.FrameRate=vid_frate;
%     v.Quality=90;
    open(v);
  end
  
  load([data_path fn{tt} '_mic_data_bp_proc.mat'])
  if d2
    bat=track.track_interp(:,[1 2]);
  else
    bat=track.track_interp;
  end
  
%   A=importdata([fn{tt} '_platformxyzpts.csv']);
%   platform1=A.data(1,1:3);
%   platform2=A.data(1,4:6);
  
  load([data_path fn{tt} '_mic_data.mat']);
  I=proc.call_psd_dB_comp_re20uPa_withbp;

  goodch=1:length(mic_loc);
%   goodch=setdiff(goodch,3);
  
  figure(1); clf; set(gcf,'pos',[10 40 800 900],'color','w')
  set(gca,'position',[.05 .05 .9 .9],'units','normalized')
  if d2
%     plot(bat(:,1),bat(:,2),'-b','linewidth',2)
    hold on;
    plot(mic_loc(goodch,1),mic_loc(goodch,2),'ok')
%     plot(platform1(1),platform1(2),'sg','markerfacecolor','g')
%     plot(platform2(1),platform2(2),'sg','markerfacecolor','g')
  else
%     plot3(bat(:,1),bat(:,2),bat(:,3),'-b','linewidth',2)
    hold on;
    plot3(mic_loc(goodch,1),mic_loc(goodch,2),mic_loc(goodch,3),'ok')
%     plot3(platform1(1),platform1(2),platform1(3),'sg','markerfacecolor','g')
%     plot3(platform2(1),platform2(2),platform2(3),'sg','markerfacecolor','g')
    view(2)
  end
  frames=find(isfinite(bat(:,1)));
  
  pb=plot(bat(frames(1:end),1),bat(frames(1:end),2),'-b','linewidth',2);
  axis equal; grid on;
  a=axis;
  delete(pb);
%   axis([-2 2.5 -2.1 3.2])
  
  call_fr=0; pm=[];
  for fr=frames(1):frames(end)
    if d2
      pb=plot(bat(frames(1):fr,1),bat(frames(1):fr,2),...
        '-b','linewidth',2);
    else
      pb=plot3(frames(1):bat(fr,1),bat(frames(1):fr,2),bat(frames(1):fr,3),...
        'ok','markerfacecolor','k','markersize',8);
    end
%     call_indx= find(proc.call_loc_on_track_interp<=fr,1,'last');
    call_present=ismember(proc.call_loc_on_track_interp,fr);
    call_indx=find(call_present);
    if ~isempty(call_indx)
      call_fr=proc.call_loc_on_track_interp(call_indx);
      Icall=cellfun(@(c) c(freqi),I(call_indx,:));
      goodch=find(isfinite(Icall));
      Icall=Icall(goodch);
%       Icall=I{call_indx}(freqi,goodch);
      if d2
        mic_vec=mic_loc(goodch,1:2)-repmat(bat(call_fr,1:2),size(mic_loc(goodch,1:2),1),1);
        norm_mic_vec=mic_vec./...
          repmat(sqrt((mic_vec(:,1).^2+mic_vec(:,2).^2)),1,2);
        I_mic_vec=norm_mic_vec.*repmat(Icall',1,2);
      else
        mic_vec=mic_loc(goodch,:)-repmat(bat(call_fr,:),size(mic_loc(goodch,:),1),1);
        norm_mic_vec=mic_vec./...
          repmat(sqrt((mic_vec(:,1).^2+mic_vec(:,2).^2+mic_vec(:,3).^2)),1,3);
        I_mic_vec=norm_mic_vec.*repmat(Icall',1,3);
      end
      norm_I_mic_vec=I_mic_vec./max(Icall).*.4;
      I_dir=mean(I_mic_vec)./norm(mean(I_mic_vec))/2;
      
      th=cart2pol(mic_vec(:,1),mic_vec(:,2));
      thdir=cart2pol(I_dir(1),I_dir(2));
      [~,sortIndx]=sort(th);
      
      pm=[];
%       for mm=1:length(goodch)
      if d2
        pm=plot(bat(call_fr,1)+norm_I_mic_vec(sortIndx,1),...
          bat(call_fr,2)+norm_I_mic_vec(sortIndx,2),'.-','color',[.4 .4 .4]);
      else
        pm(mm)=plot3(bat(call_fr,1)+norm_I_mic_vec(mm,1),...
          bat(call_fr,2)+norm_I_mic_vec(mm,2),...
          bat(call_fr,3)+norm_I_mic_vec(mm,3),'-o','color',[.4 .4 .4]);
      end
%       end
      
      if gaussfitfcn
        [sigma, thdirfit]=gaussfit(th,Icall');
      else
%         f = fit(th,Icall','gauss1');
%         thdirfit=f.b1;
        [thdirfit,sigma]=normfit(th,Icall);
      end
      [Idir(1),Idir(2)]=pol2cart(thdirfit,.45);
      
      if diag
        xp = linspace(min(th),max(th),50);
        if gaussfitfcn
          yp = 1/(sqrt(2*pi)* sigma ) * exp( - (xp-thdirfit).^2 / (2*sigma^2));
        else
  %         yp=feval(f,xp)';
          yp = 1/(sqrt(2*pi)* sigma ) * exp( - (xp-thdirfit).^2 / (2*sigma^2));
        end
        
        figure(2); clf;
        plot(th(sortIndx),Icall(sortIndx));
        hold on;
        plot(thdir,max(Icall),'+k')
        plot(xp,yp.*max(Icall).*2,'r')

        plot(thdirfit,max(Icall),'+g')

        figure(1);
      end
      
%       pd=plot3([bat(fr,1) bat(fr,1)+I_dir(1)],...
%           [bat(fr,2) bat(fr,2)+I_dir(2)],...
%           [bat(fr,3) bat(fr,3)+I_dir(3)],'k-','linewidth',2);
      pd=plot([bat(call_fr,1) bat(call_fr,1)+Idir(1)],...
        [bat(call_fr,2) bat(call_fr,2)+Idir(2)],'k-','linewidth',2);
      
%       [XD,YD]=pol2cart(xp,yp/max(yp)/2);
%       pf=plot(XD+bat(fr,1), YD+bat(fr,2),'-','color',[.4 .4 .4]);
    else
%       pm=[];
      pd=[];
%       pf=[];
    end
    
    axis(a);
    if save_movie
      writeVideo(v,getframe(gcf));
    else
      if ~isempty(call_indx) && ~save_movie
        pause(.5)
      end
      drawnow
    end
    
    delete(pb);
    if fr-call_fr > 15
      delete(pm)
      pm=[];
    end
  end
    if save_movie
      close(v);
      
      %crop the audio
      fs=250e3;
      samp1=round(frames(1)/(track.fs*10)*fs);
      samp2=min(round(frames(end)/(track.fs*10)*fs),length(sig));
      [~,ch]=max(max(sig));
      y=sig(samp1:samp2,ch);
      audiowrite([fn{tt} '.wav'],y./max(y)/2,fs/(track.fs*10/vid_frate))
    end
end