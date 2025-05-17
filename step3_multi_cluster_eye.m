%{
    clustering eye gaze through multi steps
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set file path
savedatapath = ['X:\hanyaning\human_gaze\' ...
    'data_20241119\struct_20241216_1500ms_3000ms' ...
    '\recluster_data'];

load([savedatapath,'\data_sample_cell.mat']);

load([savedatapath,'\dist_mat_all.mat']);
%% show embedding
embed = cell2mat(data_sample_cell(:,5));
figure
plot(embed(:,1),embed(:,2),'o')
%% set cut range
min_x = -10;
max_x = 10;
min_y = -10;
max_y = 10;

cent_idx = min_x<embed(:,1) & embed(:,1)<max_x & ...
    min_y<embed(:,2) & embed(:,2)<max_y;

peri_idx = ~cent_idx;

peri_embed = embed(peri_idx,:);

cent_embed = embed(cent_idx,:);

%% cluster peri_embed
n_clus = 14;
D = pdist(peri_embed,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
peri_T = cluster(tree,'maxclust',n_clus);
%% show
figure
cmaplist3 = peri_T;
cmapcolor3 = imresize(colormap('jet'),...
    [length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter(peri_embed(:,1),peri_embed(:,2),...
    10*ones(size(peri_embed(:,1))),cmap3,'filled');
axis square
% axis([-0.5,0.5,-0.5,0.5,-2,12])
xlabel('UMAP 1')
ylabel('UMAP 2')

%% cluster cent_embed
cent_dist_mat_all = dist_mat_all(cent_idx,:);
cent_dist_mat_all = cent_dist_mat_all(:,cent_idx);
%% embedding
[reduction, umap, clusterIdentifiers] = ...
    run_umap(cent_dist_mat_all,...
    'n_neighbors',100,'sgd_tasks',1,...
    'min_dist',0.05,'metric','seuclidean',...
    'n_components', 2, 'verbose', 'text');
new_embedding = umap.embedding;
%% clustering
E1 = evalclusters(new_embedding,...
    'linkage','silhouette','KList',1:50);
%% hierarchical clustering
n_clus = 21;
D = pdist(new_embedding,'seuclidean');
Z = squareform(D);
tree = linkage(Z, 'ward','euclidean');
T = cluster(tree,'maxclust',n_clus);
cent_T = T;
%% 
close all
cmaplist3 = T;
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter(new_embedding(:,1),new_embedding(:,2),...
    10*ones(size(new_embedding(:,1))),cmap3,'filled');
axis square
% axis([-0.5,0.5,-0.5,0.5,-2,12])
xlabel('UMAP 1')
ylabel('UMAP 2')
%% show
figure
subplot(131)
plot(embed(:,1),embed(:,2),'o')
axis square
subplot(132)
cmaplist3 = peri_T;
cmapcolor3 = imresize(colormap('jet'),...
    [length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter(peri_embed(:,1),peri_embed(:,2),...
    10*ones(size(peri_embed(:,1))),cmap3,'filled');
axis square
% axis([-0.5,0.5,-0.5,0.5,-2,12])
xlabel('UMAP 1')
ylabel('UMAP 2')
subplot(133)
cmaplist3 = T;
cmapcolor3 = imresize(colormap('jet'),[length(unique(cmaplist3)),3]);
cmap3 = zeros(size(cmaplist3,1),3);
for k = 1:size(cmap3,1)
    cmap3(k,:) = cmapcolor3(cmaplist3(k,1),:);
end
scatter(new_embedding(:,1),new_embedding(:,2),...
    10*ones(size(new_embedding(:,1))),cmap3,'filled');
axis square
% axis([-0.5,0.5,-0.5,0.5,-2,12])
xlabel('UMAP 1')
ylabel('UMAP 2')
%% save data
peri_T_list = zeros(size(data_sample_cell,1),1);

peri_T_list(peri_idx,:) = peri_T;

cent_T_list = zeros(size(data_sample_cell,1),1);

cent_T_list(cent_idx,:) = cent_T;

all_T_list = peri_T_list+100*cent_T_list;

all_new_embedding = zeros(size(data_sample_cell,1),2);

all_new_embedding(peri_idx,:) = peri_embed;

all_new_embedding(cent_idx,:) = new_embedding;

%% append data
double_cluster_cell = cell(size(data_sample_cell,1),6);

for k = 1:size(double_cluster_cell,1)
    double_cluster_cell{k,1} = peri_idx(k,1);
    double_cluster_cell{k,2} = peri_T_list(k,1);
    double_cluster_cell{k,3} = cent_idx(k,1);
    double_cluster_cell{k,4} = cent_T_list(k,1);
    double_cluster_cell{k,5} = all_T_list(k,1);
    double_cluster_cell{k,6} = all_new_embedding(k,:);
end

data_sample_cell = [data_sample_cell,double_cluster_cell];

%% save to disk
save([savedatapath,'\data_sample_cell_1500ms_3000ms.mat'],...
    'data_sample_cell');
disp('save!')















