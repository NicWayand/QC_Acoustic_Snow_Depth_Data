clear all; close all; clc; smp

%% Script to import and QC noisy acoustic snow depth data
 
% Data to QC
filein   = 'G:\ncar\d1\data\Point_Snow_Sites\Raw\SNQ_Hist\QC_Data.mat';
load(filein)

% Deal with time step issue
TIME_in    = QC_Data(:,1);
TIME_in_all = time_builder(TIME_in);
% dt_all = diff(TIME_in)*24; % hours

[QC_Data_out, TIME_out] = Import_intermittent_time_data_to_continuous(TIME_in,QC_Data,1);
clear QC_Data TIME_in

% New Snow is in column 17. 
SD_24_acou = in_to_m(QC_Data_out(:,17));

% Manual observations used to aid QC'ing of automatic
filein_B = 'G:\Work\e\Data\Obs\Intermitent_Snow_Forcing_Sites\SNQ\NWAC\NWAC data\Snoq_Wx_1973-2014.xlsx';
datain = importdata(filein_B);
TIME = datenum(datain.textdata(2:end,1));
TIME_all = time_builder(TIME);
Data = datain.data;
headers = datain.textdata(1,2:end);

% 2001 WY dates were incorrectly entered to the excell file ast 1900/1901
I_2000 = find(TIME_all(:,1)==1900);
I_2001 = find(TIME_all(:,1)==1901);
TIME_all(I_2000,1) = 2000;
TIME_all(I_2001,1) = 2001;
hour_force = 6;
TIME_dly_man = datenum(TIME_all(:,1),TIME_all(:,2),TIME_all(:,3),hour_force,TIME_all(:,5),0);
TIME_dly_man_all = time_builder(TIME_dly_man);
clear TIME TIME_all

SD_24_man  = cm_to_m(Data(:,7)); 

% Plot raw data
figure; hold on
plot(TIME_out(:,7),SD_24_acou,'k') 
plot(TIME_dly_man,SD_24_man,'b*')
legend('Acoustic raw','manual obs')
tlabel


% Instrument/manual uncertainty
Inst_err = 20 ./100; % m
Man_err  = 10 ./100; % m
tot_err  = Inst_err + Man_err;

% QC rules



% 1) Data before Oct 2003 are not physical
I_start_G_data = find(TIME_out(:,7)==datenum(2003,10,1));
SD_24_acou(1:I_start_G_data) = NaN;

% 2) Values higher than manual obs, and less than zero
I_high_negative = find(SD_24_acou > max(SD_24_man) | SD_24_acou < 0);
SD_24_acou(I_high_negative) = NaN;

% 3) Remove summer months (no snow)
I_summer = find(TIME_out(:,2) >= 6 & TIME_out(:,2)<= 9) ;
SD_24_acou(I_summer) = NaN;

% 4) Rate of change for hourly snow depth should be less than limit
roc_SD_24_acou = [0; diff(SD_24_acou)]; 
Max_ROC = (max(SD_24_man)/6);
I_jump = find(roc_SD_24_acou >= Max_ROC);



% Plot raw data
figure; hold on
plot(TIME_out(:,7),SD_24_acou,'k') 
% plot(TIME_out(I_jump,7),SD_24_acou(I_jump),'r*') 
plot(TIME_dly_man,SD_24_man,'b*')
legend('Acoustic raw','manual obs')
tlabel


% 5) Acoustic data 24 hours before manual sample should not be greater than
% insturment accuracy

% Agg daily man to hourly 
agg_period = 1;
agg_option = 2;
base_value = 0;
SD_24_man_hlry = disaggMET(TIME_dly_man,SD_24_man,24,1,TIME_out(:,7),...
    agg_period, agg_option,base_value);

I_high_obs = find(SD_24_acou > SD_24_man_hlry + Inst_err);
SD_24_acou(I_high_obs) = NaN;

% 6) % Assume if manual is missing there was no snow

I_missing = isnan(SD_24_man_hlry);
SD_24_acou(I_missing) = NaN;


figure; hold on
plot(TIME_out(:,7),SD_24_acou,'k')
% plot(TIME_out(I_missing,7),SD_24_acou(I_missing),'r*') 
plot(TIME_out(:,7),SD_24_man_hlry,'b*') 
legend('Acoustic raw','manual obs')
tlabel

close all

return

Ba having trouble setting up a easy way to remove data. Maybe just use QC script

save SD_24_acou.mat SD_24_acou

figure; hold on
plot(TIME_out(:,7),SD_24_acou,'k')
plot(TIME_out(:,7),SD_24_man_hlry,'b*') 
legend('Acoustic raw','manual obs')

% Get points
[pointslist,xselect,yselect] = selectdata; %('BrushShape','rect');

% remove data
SD_24_acou(pointslist) = NaN;
save SD_24_acou.mat SD_24_acou

return

% 7) Manually inspecting data by water year 2004 - 2014

WY = water_year(TIME_out);
for cWY = 16:26
    sprintf('%4.0f',WY(cWY,3))
    load('SD_24_acou.mat')

    figure; hold on
    plot(TIME_out(:,7),SD_24_acou,'k')
    % plot(TIME_out(I_missing,7),SD_24_acou(I_missing),'r*') 
    plot(TIME_out(:,7),SD_24_man_hlry,'b*') 
    legend('Acoustic raw','manual obs')
    xlim([TIME_out(WY(cWY,1),7) TIME_out(WY(cWY,2),7)])
   

    [pointslist,xselect,yselect] = selectdata('BrushShape','rect');
    
    
    
    
    disp('Paused: hit enter to save and continue')
    pause
    
    % remove data
    SD_24_acou(pointslist) = NaN;
    
    save SD_24_acou.mat SD_24_acou

end
% 
% brush on
% pause
% hBrushLine = findall(gca,'tag','Brushing');
% brushedData = get(hBrushLine, {'Xdata','Ydata'});
% brushedIdx = ~isnan(brushedData{1});
% brushedXData = brushedData{1}(brushedIdx);
% brushedYData = brushedData{2}(brushedIdx);
% 

return

    
% end

return

%% Finally load in Erics QC of the total snow depth and merge together

% Data to QC
filein2   = 'G:\ncar\d1\data\Point_Snow_Sites\Raw\SNQ_Hist\QC_Data_2.mat';
load(filein2)


return
% 
% % Find Common times
% %                     accoustic     manual
% [C, A, B]        = intersect(TIME_out(:,7),TIME_dly_man);
% SD_24_acou_trim  = SD_24_acou(A);
% SD_24_man_trim   = SD_24_man(B);

Diffval     = SD_24_acou - SD_24_man_hlry;

figure; hold on
hist((Diffval),1000)

I_agree     = abs(Diffval) <= tot_err;
I_disagree  = abs(Diffval) > tot_err;

figure; hold on
plot(TIME_out(:,7),SD_24_acou,'k') 
plot(C(I_agree),SD_24_acou_trim(I_agree),'r*') 
plot(C(I_disagree),SD_24_acou_trim(I_disagree),'k*') 
plot(C,SD_24_man_trim,'b*')
legend('Acoustic raw','agree','disagree','manual obs')
tlabel

% Remove I_disagree




















