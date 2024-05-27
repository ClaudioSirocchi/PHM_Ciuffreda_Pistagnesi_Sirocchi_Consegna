%****Cartelle di origine*****
datiTrain = 'dataset/train/data/';
datiLabel = 'dataset/train/labels.xlsx';
%****Fine Cartelle Origine****

%****Leggo i dati del test inserendo dentro la variabile data tante celle
%quanti sono i file e ogni cella contiene la tabella di un file
files = dir(fullfile(datiTrain, '*.csv')); %leggo tutti i file nella cartella
dati = cell(1, numel(files));
for i = 1:numel(files)
    percorsoFile = fullfile(datiTrain, files(i).name);
    dati{i} = readtable(percorsoFile);
end
%****Fine lettura file ****

%****Lettura label errori ****
tabellaLabel = readtable(datiLabel);
tabellaLabel = renamevars(tabellaLabel,["Var1","Var2","Var3"],["Case","Spacecraft","Condition"]);
%****Fine lettura label errori ****

% Assegna i codici Errore/NonErrore al task1
labels_codice(strcmp(tabellaLabel.Condition, 'Anomaly')| strcmp(tabellaLabel.Condition, 'Fault')) = 1;
labels_codice(strcmp(tabellaLabel.Condition, 'Normal')) = 0;

%Assegna i codici TipoErre per il task2
labels_tipo(strcmp(tabellaLabel.Condition, 'Normal')) = 0;
labels_tipo(strcmp(tabellaLabel.Condition, 'Anomaly')) = 2;
labels_tipo(strcmp(tabellaLabel.Condition, 'Fault')) = 3;

%Creo una cella che associa a ogni Case i rispettivi label
datasetStrutturato = cell(numel(dati),6);
datasetStrutturato(:, 1) = dati;
%Task1
datasetStrutturato(:, 2) = num2cell(labels_codice);
%Task2
datasetStrutturato(:, 3) = num2cell(labels_tipo);

for i = 1:numel(dati)
    % Task3
    if tabellaLabel{i,"BP1"} == "Yes"
        datasetStrutturato{i,4} = 1;
    elseif tabellaLabel{i,"BP2"} == "Yes"
        datasetStrutturato{i,4} = 2;
    elseif tabellaLabel{i,"BP3"} == "Yes"
        datasetStrutturato{i,4} = 3;
    elseif tabellaLabel{i,"BP4"} == "Yes"
        datasetStrutturato{i,4} = 4;
    elseif tabellaLabel{i,"BP5"} == "Yes"
        datasetStrutturato{i,4} = 5;
    elseif tabellaLabel{i,"BP6"} == "Yes"
        datasetStrutturato{i,4} = 6;
    elseif tabellaLabel{i,"BP7"} == "Yes"
        datasetStrutturato{i,4} = 7;
    elseif tabellaLabel{i,"BV1"} == "Yes"
        datasetStrutturato{i,4} = 8;
    else
        datasetStrutturato{i,4} = 0;
    end

    % Task4 
    if tabellaLabel{i,'SV1'}~=100
        datasetStrutturato{i,5} = 1;
    elseif tabellaLabel{i,'SV2'}~=100
        datasetStrutturato{i,5} = 2;
    elseif tabellaLabel{i,'SV3'}~=100
        datasetStrutturato{i,5} = 3;
    elseif tabellaLabel{i,'SV4'}~=100
        datasetStrutturato{i,5} = 4;
    else
        datasetStrutturato{i,5} = 0;
    end

    % Task5
    if tabellaLabel{i,'SV1'}~=100
        datasetStrutturato{i,6} = tabellaLabel{i,'SV1'};
    elseif tabellaLabel{i,'SV2'}~=100
        datasetStrutturato{i,6} = tabellaLabel{i,'SV2'};
    elseif tabellaLabel{i,'SV3'}~=100
        datasetStrutturato{i,6} = tabellaLabel{i,'SV3'};
    elseif tabellaLabel{i,'SV4'}~=100
        datasetStrutturato{i,6} = tabellaLabel{i,'SV4'};
    else
        datasetStrutturato{i,6} = 100;
    end
end
%**** Converto e formatto il dataset di train ****
datasetFinale = cell2table(datasetStrutturato);
datasetFinale = renamevars(datasetFinale,["datasetStrutturato1", ...
    "datasetStrutturato2","datasetStrutturato3","datasetStrutturato4", ...
    "datasetStrutturato5","datasetStrutturato6"], ...
    ["Case","Task1","Task2","Task3","Task4","Task5"]);