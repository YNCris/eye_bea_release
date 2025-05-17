%{
    separate eye gaze data
%}
clear all
close all
%% set path
rootpath = 'X:\hanyaning\human_gaze\data_20241119';

raw_data_path = [rootpath,'\raw_data'];

raw_data_name = 'subset_data.csv';

%% load data
tbl = readtable([raw_data_path,'\',raw_data_name]);
%% process
all_id = tbl.ID;
all_x = tbl.x;
all_y = tbl.y;
all_t = tbl.duration;

unique_id = unique(all_id);

for k = 1:size(unique_id,1)
    tempname = unique_id{k};
    selidx = strcmp(tempname,all_id);

    sel_x = all_x(selidx);
    sel_y = all_y(selidx);
    sel_t = all_t(selidx);

    raw_xy = [];
    for m = 1:size(sel_t,1)
        raw_xy = [raw_xy;...
            [sel_x(m)*ones(sel_t(m),1),...
            sel_y(m)*ones(sel_t(m),1)]];
    end
   
    csvwrite([rootpath,'\',tempname,'.csv'],raw_xy)
    
    disp(k)
end

















