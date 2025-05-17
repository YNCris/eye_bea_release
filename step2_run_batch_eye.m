clear global
clear
global BeA
data_dim = 2;
genPath = genpath('./');
addpath(genPath)
%% set save path
savepath = ['X:\hanyaning\human_gaze\data_20241119\' ...
    'struct_20241216_1500ms_3000ms'];
mkdir(savepath)
%% get filename
filepath = ['X:\hanyaning\human_gaze\data_20241119'];
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.csv'));
fileNames = {dirOutput.name}';

%% Import dataset

for iData = 1:size(fileNames,1)
    %% Import dataset
    clear global
    global BeA
    data_2d_name = [filepath,'\',fileNames{iData,1}];
    import_2d_eye(data_2d_name);

    %% Import dataset
    BeA.DataInfo.VideoInfo.FrameRate = 1000;

    %% Aanlysis -> 2. Feature Selection

    body_parts = BeA.DataInfo.Skl;
    nBodyParts = length(body_parts);
    weight = ones(1, nBodyParts);
    featNames = body_parts';
    selection = [1,1];

    for i = 1:nBodyParts
        BeA_DecParam.FS(i).featNames = body_parts{i};
        BeA_DecParam.FS(i).weight = weight(i);
    end
    BeA_DecParam.selection = selection;

    BeA.BeA_DecData.XY = [BeA.RawData.X,BeA.RawData.Y]';
    %% Aanlysis -> Behavior Decomposing

    % BeA_SegParam.L1
    BeA_DecParam.L1.ralg = 'merge';
    BeA_DecParam.L1.redL = 10;
    BeA_DecParam.L1.calg = 'kmeans';
    BeA_DecParam.L1.kF = 10;% small class get higher performance

    % BeA_SegParam.L2
    BeA_DecParam.L2.kerType = 'g';
    BeA_DecParam.L2.kerBand = 'nei';
    BeA_DecParam.L2.k = 3; % Cluster number
    BeA_DecParam.L2.nMi = 1500; % Minimum lengths (ms),raw 100
    BeA_DecParam.L2.nMa = 3000; % Maximum lengths (ms)
    BeA_DecParam.L2.Ini = 'p'; % Initialization method

    behavior_decomposing(BeA_DecParam);

    %%
    save([savepath,'\', ...
        fileNames{iData,1}(1,1:(end-4)),'_struct.mat'], 'BeA', '-v7.3')
end

