clear global
clear
global BeA
data_dim = 2;
genPath = genpath('./');
addpath(genPath)
%% set save path
savepath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\struct_all'];
mkdir(savepath)
%% get filename
filepath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\raw_data'];
fileNames = 'subset_data.csv';

%% Import dataset

clear global
global BeA
data_2d_name = [filepath,'\',fileNames];
import_2d_eye_all(data_2d_name);

%% Import dataset
BeA.DataInfo.VideoInfo.FrameRate = 1;

%% Aanlysis -> 2. Feature Selection

body_parts = BeA.DataInfo.Skl;
nBodyParts = length(body_parts);
weight = ones(1, nBodyParts);
featNames = body_parts';
selection = [1,1,1];

for i = 1:nBodyParts
    BeA_DecParam.FS(i).featNames = body_parts{i};
    BeA_DecParam.FS(i).weight = weight(i);
end
BeA_DecParam.selection = selection;

all_BeA_DecParam = [...
    BeA.RawData.X,...
    BeA.RawData.Y,...
    mat2gray(BeA.RawData.D)]';

Raw_BeA = BeA;

%% process in seg
seg_len = 1000;
start_point = (1:seg_len:size(all_BeA_DecParam,2))';
end_point = [start_point(2:end)-1;size(all_BeA_DecParam,2)];

for k = 1:size(start_point,1)
    BeA.BeA_DecData.XY = all_BeA_DecParam(...
        :,start_point(k):end_point(k));
    %% Aanlysis -> Behavior Decomposing
    
    % BeA_SegParam.L1
    BeA_DecParam.L1.ralg = 'merge';
    BeA_DecParam.L1.redL = 1;
    BeA_DecParam.L1.calg = 'kmeans';
    BeA_DecParam.L1.kF = 20;% small class get higher performance
    
    % BeA_SegParam.L2
    BeA_DecParam.L2.kerType = 'g';
    BeA_DecParam.L2.kerBand = 'nei';
    BeA_DecParam.L2.k = 10; % Cluster number
    BeA_DecParam.L2.nMi = 2000; % Minimum lengths (ms),raw 100
    BeA_DecParam.L2.nMa = 5000; % Maximum lengths (ms)
    BeA_DecParam.L2.Ini = 'p'; % Initialization method
    
    behavior_decomposing(BeA_DecParam);
    
    %%
    save([savepath,'\', ...
        fileNames(1,1:(end-4)),'_',...
        num2str(k),'_',...
        num2str(start_point(k)),'_',...
        num2str(end_point(k)),'_',...
        '_struct.mat'], 'BeA', '-v7.3')
end


