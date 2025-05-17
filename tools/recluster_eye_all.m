%{
    recluster all data
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set file path
filepath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\struct_all'];
savedatapath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\struct_all' ...
    '\recluster_data'];
mkdir(savedatapath)
%% get all BeA structs
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% load data
load_flag = true;%load data flag
tic
if load_flag
    XY_cell = cell(size(fileNames,1),1);
    ReMap_cell = cell(size(fileNames,1),1);
    Seglist_cell = cell(size(fileNames,1),1);
    V_cell = cell(size(fileNames,1),1);
    for k = 1:size(fileNames,1)
        tempBeA = load([filepath,'\',fileNames{k,1}]);
        fs = tempBeA.BeA.DataInfo.VideoInfo.FrameRate;%tempBeA.BeA.DataInfo.VideoInfo.FrameRate;
        XY_cell{k,1} = tempBeA.BeA.BeA_DecData.XY;
        ReMap_cell{k,1} = tempBeA.BeA.BeA_DecData.L2.ReMap;
        Seglist_cell{k,1} = tempBeA.BeA.BeA_DecData.L2.Seglist;
%         imagesc(tempBeA.BeA.BeA_DecData.K)
%         title(fileNames{k,1})
%         colorbar
%         pause
        disp(k)
        toc
    end
    %% save temp data
    save([savedatapath,'\recluster_raw_data.mat'],'XY_cell','ReMap_cell','Seglist_cell');
else
    load([savedatapath,'\recluster_raw_data.mat']);
end
toc
%% load raw data
rawdatapath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\raw_data'];
rawdataNames = 'subset_data.csv';

tempdata = importdata([rawdatapath,'\',rawdataNames]);

id_names = tempdata.textdata(2:end,1);
%% match subdata_struct to tempdata.textdata
match_list = cell(size(fileNames,1),3);

match_list(:,1) = fileNames;

splname = split(match_list(:,1),'_');

sel_idx = cell2mat(cellfun(@(x) str2double(x),...
    splname(:,4:5),'UniformOutput',false));

for k = 1:size(match_list,1)
    match_list{k,2} = (sel_idx(k,1):sel_idx(k,2))';
    match_list{k,3} = id_names(match_list{k,2});
end
%% create savelist
savelist_cell = cell(size(Seglist_cell,1),1);
for k = 1:size(savelist_cell,1)
    temp_Seglist = Seglist_cell{k,1};
    temp_ReMap = ReMap_cell{k,1};
    temp_savelist = zeros(size(temp_ReMap,2)-1,5);
    temp_savelist(:,1:3) = Create_savelist(temp_ReMap,temp_Seglist);
    savelist_cell{k,1} = temp_savelist;
end
%% create temp_data_sample_cell
selection = [1,1,1];
temp_data_sample_cell = [];
for k = 1:size(savelist_cell,1)
    temp_savelist = savelist_cell{k,1};
    for m = 1:size(temp_savelist,1)
        tempdata = XY_cell{k,1}(selection==1,temp_savelist(m,1):temp_savelist(m,2));
        tempV = 0;
        tempsavelist = temp_savelist(m,:);
        tempsavelist(1,5) = m;
        tempfilename = fileNames{k,1};
        temp_data_sample_cell = [temp_data_sample_cell;{tempdata,tempsavelist,tempfilename,tempV}];
    end
end

%% change name in tt_dsc
tt_dsc = [];
for k = 1:size(temp_data_sample_cell,1)
    %%
    tempname = temp_data_sample_cell{k,3};
    selidx = strcmp(tempname,match_list(:,1));

    sel_match_list = match_list(selidx,:);

    tempsavelist = temp_data_sample_cell{k,2};

    tt_name = sel_match_list{1,3}(...
        tempsavelist(1):tempsavelist(2));

    tt_dsc = [tt_dsc;...
        {temp_data_sample_cell{k,1},...
        tempsavelist,...
        tt_name,...
        temp_data_sample_cell{k,4}}];

    if rem(k,1000) == 0
        disp(k)
    end
end
%% create data_sample_cell
data_sample_cell = [];
count = 1;
for k = 1:size(tt_dsc,1)
    tempname = tt_dsc{k,3};
    
    unique_name = unique(tempname);

    if size(unique_name,1) == 1
        data_sample_cell = [data_sample_cell;...
            tt_dsc(k,:)];
    else
        name_idx = zeros(size(tempname,1),1);
        for m = 1:size(name_idx,1)
            ttname = tempname{m,1};
            name_idx(m,1) = find(...
                strcmp(ttname,unique_name));
        end

        savelistlist = ...
            tt_dsc{k,2}(1):tt_dsc{k,2}(2);

        tempsavelist = idx2savelist(name_idx);

        for m = 1:size(tempsavelist,1)
            start_idx = tempsavelist(m,1);
            end_idx = tempsavelist(m,2);

            tt_dsc_1 = tt_dsc{k,1}(:,...
                start_idx:end_idx);
            
            tt_dsc_2 = zeros(1,5);

            tt_dsc_2(1:2) = savelistlist(:,...
                [start_idx,end_idx]);

            tt_dsc_3 = unique(tt_dsc{k,3}(...
                start_idx:end_idx,:));
            tt_dsc_3 = tt_dsc_3{1};

            tt_dsc_4 = 0;

            data_sample_cell = [data_sample_cell;...
            {tt_dsc_1,tt_dsc_2,tt_dsc_3,tt_dsc_4}];
        end
        disp('break point')
        disp(count)
        count = count+1;
    end
end
%% calculate dtak
tic
dist_mat = zeros(size(data_sample_cell,1),size(data_sample_cell,1));
for m = 1:size(data_sample_cell,1)
    for n = m:size(data_sample_cell,1)
        %% get data
        seg_data1 = data_sample_cell{m,1}(:,1:end);
        seg_data2 = data_sample_cell{n,1}(:,1:end);
        %% calculate dtak
		condist_mat = conDist(seg_data1,seg_data2);
		Kdistmat = conKnl_DTAK(...
            condist_mat, 'g', 'nei', 1);
		wFs1 = ones(1,size(Kdistmat,1));
		wFs2 = ones(1,size(Kdistmat,2));
		[T,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
        dist_mat(m,n) = T;
    end
    disp(m/size(data_sample_cell,1))
end
toc
%% fill full matrix
dist_mat_all = dist_mat + triu(dist_mat, 1)';
%% embedding
% [reduction, umap, clusterIdentifiers] = run_umap(dist_mat_all,...
%     'n_neighbors',199,'sgd_tasks',1,...
%     'min_dist',0.05,'metric','seuclidean','n_components', 2, 'verbose', 'text');
[reduction, umap, clusterIdentifiers] = run_umap(...
    mat2gray(dist_mat_all),...
    'n_neighbors',199,'sgd_tasks',1,...
    'min_dist',0.05,'metric','seuclidean','n_components', 2, 'verbose', 'text');
embedding = umap.embedding;
% plot(embedding(:,1),embedding(:,2),'o')
% axis square
% embedding = tsne(dist_mat_all,'Perplexity',5);
plot(embedding(:,1),embedding(:,2),'o')
axis square
%% data_sample_cell reassignment
for k = 1:size(data_sample_cell,1)
    data_sample_cell{k,5} = embedding(k,:);
end
% save('.\data\data_sample_cell.mat','data_sample_cell')
%%
%% hierarchical clustering
n_clus = 80;
D = pdist(embedding,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
T = cluster(tree,'maxclust',n_clus);
% cutoff = median([tree(end-2,3) tree(end-1,3)]);
% dendrogram(tree,'ColorThreshold',cutoff)
% 
best_label_embedding = [embedding,T];
%% 
close all
cmaplist3 = best_label_embedding(:,3);
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter(best_label_embedding(:,1),best_label_embedding(:,2),...
    10*ones(size(best_label_embedding(:,1))),cmap3,'filled');
axis square
% axis([-0.5,0.5,-0.5,0.5,-2,12])
xlabel('UMAP 1')
ylabel('UMAP 2')
zlabel('Speed')
%% data_sample_cell add data
for k = 1:size(data_sample_cell,1)
    data_sample_cell{k,2}(1,4) = best_label_embedding(k,3);
end

%% save data
save([savedatapath,'\dist_mat_all.mat'],'dist_mat_all','-v7.3');
save([savedatapath,'\embedding.mat'],'best_label_embedding','-v7.3');
save([savedatapath,'\data_sample_cell.mat'],'data_sample_cell','-v7.3');
disp('save finished!');
































