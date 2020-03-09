clear all
digitDatasetPath = fullfile('C:\Users\Berkin\Desktop\imaging\img');


imds.ReadSize = 500;
rng(0)
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.95,0.025);
dsTrainNoisy = transform(imdsTrain,@addNoise);
dsValNoisy = transform(imdsVal,@addNoise);
dsTestNoisy = transform(imdsTest,@addNoise);

dsTrain = combine(dsTrainNoisy,imdsTrain);
dsVal = combine(dsValNoisy,imdsVal);
dsTest = combine(dsTestNoisy,imdsTest);

dsTrain = transform(dsTrain,@commonPreprocessing);
dsVal = transform(dsVal,@commonPreprocessing);
dsTest = transform(dsTest,@commonPreprocessing);

dsTrain = transform(dsTrain,@augmentImages);

exampleData = preview(dsTrain);
inputs = exampleData(:,1);
responses = exampleData(:,2);
minibatch = cat(2,inputs,responses);
montage(minibatch','Size',[8 2])
title('Inputs (Left) and Responses (Right)')


residualW1 = convolution2dLayer(1,3,'Padding','same','Name','B1residualWeights');
%residualW2 = convolution2dLayer(1,3,'Padding','same','Name','B2residualWeights');
%residualW3 = convolution2dLayer(1,3,'Padding','same','Name','B3residualWeights');
%residualW4 = convolution2dLayer(1,3,'Padding','same','Name','B4residualWeights');

%divisionW1 = convolution2dLayer(1,3,'Padding','same','Name','divisionW1');
%divisionW2 = convolution2dLayer(1,3,'Padding','same','Name','divisionW2');
% divisionW3 = convolution2dLayer(1,3,'Padding','same','Name','divisionW3');
% divisionW4 = convolution2dLayer(1,3,'Padding','same','Name','divisionW4');

imageLayer = imageInputLayer([128,128,3],'Name','inputLayer');

regLayer = regressionLayer('Name','regLayer');

% encodingLayers = [ ...
%     convolution2dLayer(3,16,'Padding','same','Name','conv1'), ...
%     reluLayer('Name','relu1'), ...
%     maxPooling2dLayer(2,'Padding','same','Stride',2,'Name','maxPool1'), ...
%     convolution2dLayer(3,8,'Padding','same','Name','conv2'), ...
%     reluLayer('Name','relu2'), ...
%     maxPooling2dLayer(2,'Padding','same','Stride',2,'Name','maxPool2'), ...
%     convolution2dLayer(3,8,'Padding','same','Name','conv3'), ...
%     reluLayer('Name','relu3'), ...
%     maxPooling2dLayer(2,'Padding','same','Stride',2,'Name','maxPool3')];
%
% decodingLayers = [ ...
%     createUpsampleTransponseConvLayer(2,8,'upSampler1'), ...
%     reluLayer('Name','relu4'), ...
%     createUpsampleTransponseConvLayer(2,8,'upSampler2'), ...
%     reluLayer('Name','relu5'), ...
%     createUpsampleTransponseConvLayer(2,16,'upSampler3'), ...
%     reluLayer('Name','relu6'), ...
%     convolution2dLayer(3,1,'Padding','same','Name','conv4'), ...
%     clippedReluLayer(1.0,'Name','reluClipped'), ...
%     additionLayer(2,'Name','add11'), ...
%     regressionLayer('Name','regLayer')];    

%layers = [imageLayer,layerBlock('B1'),divisionW1,layerBlock('B2'),divisionW2,layerBlock('B3'),divisionW3,layerBlock('B4'),divisionW4,regLayer];
layers = [imageLayer,layerBlock('B1'),regLayer];
% layers = [layers,encodingLayers,decodingLayers];
% layers = [layers,encodingLayers,decodingLayers];
% layers = [layers,encodingLayers,decodingLayers];
%

lgraph = layerGraph(layers);
figure('Units','normalized','Position',[0.2 0.2 0.6 0.6]);
plot(lgraph);

lgraph = addLayers(lgraph,residualW1);
% lgraph = addLayers(lgraph,residualW2);
% lgraph = addLayers(lgraph,residualW3);
% lgraph = addLayers(lgraph,residualW4);


lgraph = connectLayers(lgraph,'inputLayer','B1residualWeights');
lgraph = connectLayers(lgraph,'B1residualWeights','B1add11/in2');
lgraph = connectLayers(lgraph,'inputLayer','B1add11/in3');


% lgraph = connectLayers(lgraph,'inputLayer','B2residualWeights');
% lgraph = connectLayers(lgraph,'B2residualWeights','B2add11/in2');
% lgraph = connectLayers(lgraph,'B1add11','B2add11/in3');
% 
% lgraph = connectLayers(lgraph,'inputLayer','B3residualWeights');
% lgraph = connectLayers(lgraph,'B3residualWeights','B3add11/in2');
% lgraph = connectLayers(lgraph,'B2add11','B3add11/in3');
% 
% lgraph = connectLayers(lgraph,'inputLayer','B4residualWeights');
% lgraph = connectLayers(lgraph,'B4residualWeights','B4add11/in2');
% lgraph = connectLayers(lgraph,'B3add11','B4add11/in3');

%lgraph = connectLayers(lgraph,'B1regLayer','B2conv1');

figure('Units','normalized','Position',[0.2 0.2 0.6 0.6]);
plot(lgraph);

options = trainingOptions('adam', ...
    'MaxEpochs',2000, ...
    'InitialLearnRate',0.001, ...
    'MiniBatchSize',imds.ReadSize, ...
    'ValidationData',dsVal, ...
    'Shuffle','never', ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(dsTrain,lgraph,options);

ypred = predict(net,dsTest);
inputImageExamples = preview(dsTest);
montage({inputImageExamples{1},ypred(:,:,:,1)});
function dataOut = addNoise(data)

dataOut = data;
for idx = 1:size(data,1)
   dataOut{idx} = imnoise(data{idx},'gaussian',0,0.05);
end

end

function dataOut = commonPreprocessing(data)

dataOut = cell(size(data));
for col = 1:size(data,2)
    for idx = 1:size(data,1)
        temp = single(data{idx,col});
        temp = imresize(temp,[128,128]);
        temp = rescale(temp);
        dataOut{idx,col} = temp;
    end
end
end

function dataOut = augmentImages(data)

dataOut = cell(size(data));
for idx = 1:size(data,1)
    rot90Val = randi(4,1,1)-1;
    dataOut(idx,:) = {rot90(data{idx,1},rot90Val),rot90(data{idx,2},rot90Val)};
end
end

function out = createUpsampleTransponseConvLayer(factor,numFilters,name)

filterSize = 2*factor - mod(factor,2);
cropping = (factor-mod(factor,2))/2;
numChannels = 1;

out = transposedConv2dLayer(filterSize,numFilters, ...
    'NumChannels',numChannels,'Stride',factor,'Cropping',cropping,'Name',name);
end

function layerReturn = layerBlock(tag)
    encodingLayers = [ ...
    convolution2dLayer(3,16,'Padding','same','Name',[tag, 'conv1']), ...
    reluLayer('Name',[tag, 'relu1']), ...
    maxPooling2dLayer(2,'Padding','same','Stride',2,'Name',[tag, 'maxPool1']), ...
    convolution2dLayer(3,8,'Padding','same','Name',[tag, 'conv2']), ...
    reluLayer('Name',[tag, 'relu2']), ...
    maxPooling2dLayer(2,'Padding','same','Stride',2,'Name',[tag, 'maxPool2']), ...
    convolution2dLayer(3,8,'Padding','same','Name',[tag, 'conv3']), ...
    reluLayer('Name',[tag, 'relu3']), ...
    maxPooling2dLayer(2,'Padding','same','Stride',2,'Name',[tag, 'maxPool3'])];

    decodingLayers = [ ...
    createUpsampleTransponseConvLayer(2,8,[tag, 'upSampler1']), ...
    reluLayer('Name',[tag, 'relu4']), ...
    createUpsampleTransponseConvLayer(2,8,[tag, 'upSampler2']), ...
    reluLayer('Name',[tag, 'relu5']), ...
    createUpsampleTransponseConvLayer(2,16,[tag, 'upSampler3']), ...
    reluLayer('Name',[tag, 'relu6']), ...
    convolution2dLayer(3,3,'Padding','same','Name',[tag, 'conv4']), ...
    clippedReluLayer(1.0,'Name',[tag, 'reluClipped']), ...
    additionLayer(3,'Name',[tag, 'add11'])];
   % regressionLayer('Name',[tag, 'regLayer'])];    
    layerReturn = [encodingLayers decodingLayers];
end
