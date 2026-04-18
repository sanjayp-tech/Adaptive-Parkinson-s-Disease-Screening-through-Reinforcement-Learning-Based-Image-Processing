clc
clear 
close all

%% This code contains HOG features extraction and save those features
path='datasets/training_set/';
pathFiles=dir(path);
ind=1;
for i=3:length(pathFiles)
    folderPath=[path pathFiles(i).name]
    FoldFiles=dir([folderPath '/*.png']);
    for i1=1:length(FoldFiles)
        imgFiles=imread([folderPath '\' FoldFiles(i1).name]);
        
%         imgFiles=segment_leaf(imgFiles);
        grayImage=rgb2gray(imgFiles);
       resImage=imresize(grayImage,[150,150]);
        FeatureVector=HOG(resImage);
        combinedData(ind,:)=[num2cell(FeatureVector') num2cell(pathFiles(i).name)];
        ind=ind+1;
    end
end

save combinedData combinedData