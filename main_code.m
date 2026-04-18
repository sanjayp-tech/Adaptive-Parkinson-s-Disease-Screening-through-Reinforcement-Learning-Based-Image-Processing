clc;
clear;
close all;
warning off all;

% Load data
load combinedData;
Data = cell2mat(combinedData(:,1:81));

% Select input image
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.tif';'*.gif';'*.png'}, 'Pick an image');
input1 = imread([pathname, filename]);
Al1 = imresize(input1, [150,150]);
c1 = 0; c2 = 0; c3 = 0;

for i = 1
    %% Convert to grayscale
    A = rgb2gray(input1);
    Al = imresize(A, [150,150]);
    
    %% Image PreProcessing
    A = wiener2(Al, [3 3]);
    A = histeq(A);
    
    %% Image Segmentation
    extractG(input1);
    A1 = segment(Al1);

    %% Feature Extraction
    hogFeats = HOG(Al);  
    distance = dist2(Data, hogFeats');
    
    %% Image Classification
    [minVal, minInd] = min(distance);
    coin = combinedData(minInd, 82);
    ct = str2num(cell2mat(coin));

    %% Show classification result
    if ct == 1
        resultText = 'NORMAL';
    elseif ct == 2
        resultText = 'PARKINSON DISEASE FOUND';
    else
        resultText = 'TRY ANOTHER IMAGE';
    end
end

%% Performance Evaluation
classifier1;
Sensitivity = (Tp./(Tp+Fn)) .* 100;
Specificity = (Tn./(Tn+Fp)) .* 100; 
Accuracy = ((Tp+Tn)./(Tp+Tn+Fp+Fn)) .* 100;

disp('Performance Parameters:');
display(Sensitivity);
display(Specificity);
display(Accuracy);

%% ---- SINGLE PAGE OUTPUT ----
figure('Name', 'Single Page Output Summary', 'NumberTitle', 'off', 'Position', [100 100 1200 700]);

% --- Subplot 1: Original Image ---
subplot(2,3,1);
imshow(input1);
title('Input RGB Image', 'FontWeight', 'bold');

% --- Subplot 2: GLCM Feature Image ---
subplot(2,3,2);
imshow(A, []);
title('GLCM FEATURE (Preprocessed)', 'FontWeight', 'bold');

% --- Subplot 3: Feature Extracted Image ---
subplot(2,3,3);
imshow(A1, []);
title('Feature Extracted Image (GLCM)', 'FontWeight', 'bold');

% --- Subplot 4: Reconstructed Image (if available) ---
subplot(2,3,4);
if exist('reconstructed_image', 'var')
    imshow(reconstructed_image, []);
    title('Reconstructed Image', 'FontWeight', 'bold');
else
    imshow(Al, []);
    title('Reconstructed Image (Default)', 'FontWeight', 'bold');
end

% --- Subplot 5: Segmented Image (if available) ---
subplot(2,3,5);
if exist('segmented_image', 'var')
    imshow(segmented_image, []);
    title('Segmentation Result', 'FontWeight', 'bold');
else
    imshow(input1, []);
    title('Segmentation Result (Default)', 'FontWeight', 'bold');
end

% --- Subplot 6: Accuracy Graph ---
subplot(2,3,6);
plot(ind, CNN1, 'ro-', 'LineWidth', 1.5); hold on;
plot(ind, mini_dist, 'bo-', 'LineWidth', 1.5);
legend('RIL', 'Minimum Distance Classifier', 'Location', 'SouthEast');
xlabel('DATASET SIZE');
ylabel('Accuracy');
title('Classifier Accuracy Comparison', 'FontWeight', 'bold');
grid on;

% --- Add classification result as annotation ---
annotation('textbox', [0.35 0.92 0.4 0.05], 'String', ...
    ['Classification Result:  ' upper(resultText)], ...
    'FontSize', 12, 'FontWeight', 'bold', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'Color', 'r');

