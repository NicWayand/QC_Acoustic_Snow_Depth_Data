function SD_corr = correct_SD_for_speed_of_sound(SDin,Airtemp,TIME,smooth_flag)

% This function corrects raw snow depth values measured using an acoustic
% insturment, that has been calibrated to report snow depths a 0 degrees C.
% Optional argument to smooth noisy snow depth data
%
% Taken from Campbell Scientific SR50A manual or Judd Communications snow depth sensor manual (http://static1.1.sqspcdn.com/static/f/1146254/15414722/1322862508567/ds2manual.pdf?token=Ms9OyM0XgFH696IDFumUKMIm93Y%3D)
%
% RELEASE NOTES
%   Coded into Matlab by Nic Wayand (nicway@gmail.com) June 20015
% 
% SYNTAX
%   correct_SD_for_speed_of_sound(SDin,Airtemp,TIME,smooth_flag)
% 
% INPUTS
% SDin          - Nx1 Raw measured snow depth (any length unit)
% Airtemp       - Nx1 Air Temperature (C)    
% TIME          = Nx1 Matlab format time
% smooth_flag   - Flag to smooth data after correction true/false
%
% OUTPUTS
% SD_corr    - Nx1 Corrected  snow depth (any length unit)
% 
% SCRIPTS REQUIRED
%  fastsmooth - http://www.mathworks.com/matlabcentral/fileexchange/19998-fast-smoothing-function/content/fastsmooth.m
%  get_dt     - https://github.com/NicWayand/Time_managment
%
%% Code %%

% Temperature correction (Campbell manual)
SD_corr = SDin.*sqrt((Airtemp+273.15)/273.15);

% Fill in original obs_SD when Air temp is NaN
SD_corr(isnan(Airtemp)) = SDin(isnan(Airtemp));
sprintf('Missing %f percent air temp, replacing orginal snow depth\n for these time steps\n',...
    sum(isnan(Airtemp))./numel(Airtemp).*100)

if smooth_flag
    disp('Smoothing data')
    % Smooth acoustic snowdepth data
    I_nan               = isnan(SD_corr);
    dt_obs              = get_dt(TIME);
    SD_corr_sm          = nan(size(SD_corr));
    SD_corr_sm(~I_nan)  = fastsmooth(SD_corr_sm(~I_nan),24*1/dt_obs,1,1);
    % Replace 
    SD_corr             = SD_corr_sm;
end

% END
