function body_alignment(BA)
% animal body skeleton alignment
%
% Input
%   BA    -  body alignment parameters, 1 x 1 (struct)
%       - BA.Cen                - the flag of centering skeleton
%       - BA.VA                 - the flag of skeleton vector align
%       - BA.CenIndex           - the index of center point
%       - BA.VAIndex            - the index of vector point
%   data_dim      -  2d data or 3d data, you can input 2 or 3, 1 x 1(int)
%
% Output
%   global BeA.PreproData 
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-04-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA

%% varible connection--read

cenflag = BA.Cen;
VAflag = BA.VA;
CenIndex = BA.CenIndex;
VAIndex = BA.VAIndex;
SDSize = BA.SDSize;
SDSDimens = BA.SDSDimens;

FatScale = BA.FatScale;
FatIndex = BA.FatIndex;


BA_X = BeA.PreproData.X';
BA_Y = BeA.PreproData.Y';

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% varible re-assignment


raw_XY = [];
for k = 1:size(BA_X,1)
    raw_XY = [raw_XY;BA_X(k,:);BA_Y(k,:)];	
end


%% body alignment
if cenflag == 1 && VAflag ~=1
    mean_X = mean(raw_XY(1:2:(end-1),:));
    mean_Y = mean(raw_XY(2:2:end,:));
    white_XY = raw_XY;
    white_XY(1:2:(end-1),:) = white_XY(1:2:(end-1),:)-mean_X;
    white_XY(2:2:end,:) = white_XY(2:2:end,:)-mean_Y;
    back_X = white_XY((CenIndex*2-1),:);
    back_Y = white_XY((CenIndex*2),:);
    back_XY = white_XY;
    back_XY(1:2:(end-1),:) = back_XY(1:2:(end-1),:)-back_X;
    back_XY(2:2:end,:) = back_XY(2:2:end,:)-back_Y;
    out_XY = back_XY;
elseif cenflag == 1 && VAflag == 1
    mean_X = mean(raw_XY(1:2:(end-1),:));
    mean_Y = mean(raw_XY(2:2:end,:));
    white_XY = raw_XY;
    white_XY(1:2:(end-1),:) = white_XY(1:2:(end-1),:)-mean_X;
    white_XY(2:2:end,:) = white_XY(2:2:end,:)-mean_Y;
    back_X = white_XY((CenIndex*2-1),:);
    back_Y = white_XY((CenIndex*2),:);
    back_XY = white_XY;
    back_XY(1:2:(end-1),:) = back_XY(1:2:(end-1),:)-back_X;
    back_XY(2:2:end,:) = back_XY(2:2:end,:)-back_Y;
    root_tail_X = back_XY((VAIndex*2-1),:);
    root_tail_Y = back_XY((VAIndex*2),:);
    rot_alpha = -atan2(root_tail_Y,root_tail_X);
    rot_XY = zeros(size(back_XY));
    for m = 1:size(rot_alpha,2)
        rot_mat = [cos(rot_alpha(1,m)),sin(rot_alpha(1,m)),0;...
                    -1*sin(rot_alpha(1,m)),cos(rot_alpha(1,m)),0;...
                    0,0,1];
        temp_rot = ...
            [back_XY(1:2:(end-1),m),back_XY(2:2:end,m),ones(size(rot_XY,1)/2,1)]*rot_mat;
        rot_XY(1:2:(end-1),m) = temp_rot(:,1);
        rot_XY(2:2:end,m) = temp_rot(:,2);
    end
    out_XY = rot_XY;
else
    out_XY = raw_XY;
    newinfo = 'without alignment';
    addMes2log(1, newinfo, 0, 1, 0, 0, 0)
end


%% body size correction
temp_XY = out_XY;
body_size = (temp_XY(SDSDimens(1,1),:).^2+temp_XY(SDSDimens(1,2),:).^2).^0.5;
median_index = median(body_size);
corr_prop = SDSize./median_index;
out_XY = temp_XY*corr_prop;
%% body fat correction
Fat_width = zeros(size(FatIndex,1),1);

for k = 1:size(FatIndex,1)
    left_idx = FatIndex(k,1);
    right_idx = FatIndex(k,2);
    left_out_XY = out_XY(left_idx,:);
    right_out_XY = out_XY(right_idx,:);

    fat_dist = (right_out_XY-left_out_XY);
    Fat_width(k,1) = mean(fat_dist);
end
mean_Fat_width = mean(Fat_width);

fat_prop = FatScale/mean_Fat_width;

out_XY(2:3:end,:) = fat_prop*out_XY(2:3:end,:);
%% varible connection--write

BeA.BeA_DecParam.BA = BA;
BeA.BeA_DecData.XY = out_XY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%





















