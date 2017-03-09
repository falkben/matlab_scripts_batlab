function X=calc_bat_pos_using_tdoa(delays,mics,c)
%delays is a n x 1 of the arrival times in seconds on each microphone of the signal
%mics is a n x 3 of the positions in xyz of each microphone
%X is the 4 x 1 which is the [x; y; z; D], or the position of the bat, xyz, and the distance between the bat, D, which is the distance to nearest microphone D

if nargin<3
  c=344; %m/s
end

[M,min_idx]=min(delays); %the minimum delay is going to be our reference
rel_del = delays-M; %this gives us the TDOA (time difference of arrival)
rel_del(min_idx)=[]; %removing our reference from the calculation
mic_ref=mics(min_idx,:); %position of our reference microphone
mics(min_idx,:)=[]; %removing the reference microphone

d=rel_del.*c; %convert the relative time offsets to distance in meters

%setting up system of equations to solve
% Gillette, M. D., & Silverman, H. F. (2008). A Linear Closed-Form Algorithm for Source Localization From Time-Differences of Arrival. IEEE Signal Processing Letters, 15, 1–4. https://doi.org/10.1109/LSP.2007.910324
% equation 12:
A=[mic_ref(1)-mics(:,1) mic_ref(2)-mics(:,2) mic_ref(3)-mics(:,3) d]; 
w=nan(length(d),1);
for mm=1:length(d)
  w(mm)=1/2.*(d(mm).^2 - mics(mm,1).^2 + mic_ref(1)^2 ...
    - mics(mm,2).^2 + mic_ref(2)^2 ...
    - mics(mm,3).^2 + mic_ref(3)^2 );
end


%solving for bat position

% AT=(A'*A)^(-1)*A';
% X=AT*w;

X=A\w;
