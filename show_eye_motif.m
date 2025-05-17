%{
    show eye motif
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
%% show
savelist_all = cell2mat(data_sample_cell(:,2));
T = savelist_all(:,4);

unique_T = unique(T);

%% show first 20
cmap = cbrewer2('Spectral',80);

temph = figure(1);
for m = 15:length(unique_T)
    selidx = m;
    seldata = data_sample_cell(selidx==T,1);
    title_list = data_sample_cell(selidx==T,3);

    dist_mat = zeros(size(seldata,1),...
        size(seldata,1));
    for p = 1:size(seldata,1)
        for q = p:size(seldata,1)
            %% get data
            seg_data1 = seldata{p,1}(:,1:20:end);
            seg_data2 = seldata{q,1}(:,1:20:end);
            %% calculate dtak
		    condist_mat = conDist(seg_data1,seg_data2);
		    Kdistmat = conKnl_DTAK(...
                condist_mat, 'g', 'nei', 1);
		    wFs1 = ones(1,size(Kdistmat,1));
		    wFs2 = ones(1,size(Kdistmat,2));
		    [tempT,~,~] = dtakFord(Kdistmat,0,wFs1,wFs2);
            dist_mat(p,q) = tempT;
        end
        disp(p/size(seldata,1))
    end
    dist_mat_all = dist_mat + triu(dist_mat, 1)';
    
    D = pdist(dist_mat_all,'euclidean');
    Z = squareform(D);
    tree = linkage(Z, 'ward','euclidean');
    order = optimalleaforder(tree, D);

    try
        for k = 1:30
            %%
            subplot(5,6,k)
            
            plot(seldata{order(k)}(1,:),...
                seldata{order(k)}(2,:),...
                '-k')
            hold on
            plot(seldata{order(k)}(1,1),...
                seldata{order(k)}(2,1),...
                'ob')
            hold on
            plot(seldata{order(k)}(1,end),...
                seldata{order(k)}(2,end),...
                'or')
            hold off
        
            axis([0,1,0,1])
            
            set(gca, 'YDir', 'reverse');
            if size(title_list{k},1) == 1
                title(title_list{k},...
                    'Interpreter','none')
            else
                title(title_list{k}{1},...
                    'Interpreter','none')
            end
        end
    catch
        for k = 1:size(seldata,1)
            %%
            subplot(5,6,k)
            
            plot(seldata{order(k)}(1,:),...
                seldata{order(k)}(2,:),...
                '-k')
            hold on
            plot(seldata{order(k)}(1,1),...
                seldata{order(k)}(2,1),...
                'ob')
            hold on
            plot(seldata{order(k)}(1,end),...
                seldata{order(k)}(2,end),...
                'or')
            hold off
        
            axis([0,1,0,1])
            set(gca, 'YDir', 'reverse');
            
            title(unique(title_list{k}),...
                'Interpreter','none')
        end
    end

    data = getframe(temph);

    img = data.cdata;

    imwrite(img,[savedatapath,'\',num2str(m),'.png']);
end




