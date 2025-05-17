function import_2d(data_2d_name)
% import the data from dlc
%
% Input
%   data_3d_name       -  path and name of csv file, 1 x 1 (string)
%
% Output
%   BeA                -  saving all data, 1 x 1 (struct)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-02-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA

%% transform data_3d_name to path and name

for k = 1:size(data_2d_name,2)
    if data_2d_name(1,size(data_2d_name,2)-k+1) == '/'||data_2d_name(1,size(data_2d_name,2)-k+1) == '\'
        BeA.DataInfo.FileName = data_2d_name(1,(size(data_2d_name,2)-k+2):end);
        BeA.DataInfo.FilePath = data_2d_name(1,1:(size(data_2d_name,2)-k+1));
        break;
    end
end

%% import data
tempdata = importdata(data_2d_name);
BeA.RawData.X = tempdata.data(:,2:3:end);
BeA.RawData.Y = tempdata.data(:,3:3:end);

%% import skeleton
BeA.DataInfo.Skl = cell(size(BeA.RawData.X,2),1);
BeA.DataInfo.Skl{1,1} = 'Nose';
BeA.DataInfo.Skl{2,1} = 'Center';
BeA.DataInfo.Skl{3,1} = 'Left_Arm';
BeA.DataInfo.Skl{4,1} = 'Right_Arm';
BeA.DataInfo.Skl{5,1} = 'Left_Leg';
BeA.DataInfo.Skl{6,1} = 'Right_Leg';
BeA.DataInfo.Skl{7,1} = 'AG_area';
BeA.DataInfo.Skl{8,1} = 'Tail_base';
BeA.DataInfo.Skl{9,1} = 'Tail_end';
%% indicate the data source
BeA.DataInfo.Source = '2D';


% BeA