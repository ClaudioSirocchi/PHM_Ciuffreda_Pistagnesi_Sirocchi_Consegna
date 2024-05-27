clc;
clear all;

dataFolder = 'dataset/train/data/';
files = dir(fullfile(dataFolder, '*.csv'));

data = cell(1, numel(files));
for i = 1:numel(files)
    filePath = fullfile(dataFolder, files(i).name);
    data{i} = readtable(filePath);
end

labelsFile = 'dataset/train/labels.xlsx';
labelsTable = readtable(labelsFile);
labelsTable = renamevars(labelsTable,["Var1","Var2","Var3"],["Case","Spacecraft","Condition"]);
labels = labelsTable.Condition; 

X = data;

% sostituisco le etichette
labels(strcmp(labels, 'Normal')) = {'0'};
labels(strcmp(labels, 'Anomaly')) = {'1'};
labels(strcmp(labels, 'Fault')) = {'1'};
labels = str2double(labels);

% associo a ogni campione l'etichetta abnormal o normal
labeledData = cell(numel(X),2);

for i = 1:numel(X)
    labeledData{i, 1} = X{i};
    
    % Task2: associo a ogni campione l'etichetta bubble, solenoid o unknown
    if labelsTable{i, "Condition"} == "Normal"
        labeledData{i, 2} = 'toDrop';
    elseif labelsTable{i,"SV1"}~=100 || labelsTable{i,"SV2"}~=100 || labelsTable{i,"SV3"}~=100 || labelsTable{i,"SV4"}~=100
        labeledData{i, 2} = 3;
    elseif labelsTable{i,"BP1"}=="Yes" || labelsTable{i,"BP2"}=="Yes" || labelsTable{i,"BP3"}=="Yes" || labelsTable{i,"BP4"}=="Yes" || labelsTable{i,"BP5"}=="Yes" || labelsTable{i,"BP6"}=="Yes" || labelsTable{i,"BP7"}=="Yes" || labelsTable{i,"BV1"}=="Yes"
         labeledData{i, 2} = 2;
    else 
        labeledData{i, 2} = 1;
    end    

end

labeledData = cell2table(labeledData);
labeledData = renamevars(labeledData,["labeledData1","labeledData2"],["Case","Task2"]);
toDelete = strcmp(labeledData.Task2, "toDrop");
labeledData(toDelete,:) = [];
Case = labeledData.Case;
Task2 = cell2mat(labeledData.Task2);
labeledData = table(Case,Task2);