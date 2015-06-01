clear all; close all; clc;

%% Script to import and QC noisy acoustic snow depth data
 
% Data to QC
% New Snow is in column 17. 
filein   = 'G:\ncar\d1\data\Point_Snow_Sites\Raw\SNQ_Hist\QC_Data.mat';
load(filein)

% Deal with time step issue
SD_24_acou = QC_Data(:,17);
TIME_in    = QC_Data(:,1);
dt_all = diff(TIME_in)*24; % hours

[QC_Data_out, TIME_out] = Import_intermittent_time_data_to_continuous(TIME_in,QC_data);


% Manual observations used to aid QC'ing of automatic
filein_B = 'G:\Work\e\Data\Obs\Intermitent_Snow_Forcing_Sites\SNQ\NWAC\NWAC data\Snoq_Wx_1973-2014 (NWAC edited by Eric).xlsx';
datain = importdata(filein);
TIME = datenum(datain.textdata(2:end,1));
TIME_all = time_builder(TIME);
Data = datain.data;
headers = datain.textdata(1,2:end);

% 2001 WY dates were incorrectly entered to the excell file ast 1900/1901
I_2000 = find(TIME_all(:,1)==1900);
I_2001 = find(TIME_all(:,1)==1901);
TIME_all(I_2000,1) = 2000;
TIME_all(I_2001,1) = 2001;
TIME_dly_man = datenum(TIME_all(:,1),TIME_all(:,2),TIME_all(:,3),TIME_all(:,4),TIME_all(:,5),0);
TIME_dly_man_all = time_builder(TIME_dly_man);
clear TIME TIME_all

SD_24  = cm_to_m(Data(:,7)); % cm to meters


