%****Cartelle di origine*****
datiTrain = 'dataset/test/data/';
datiLabel = 'dataset/test/labels_spacecraft.xlsx';
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

%****Inserisco i dati del segnale nella struttura ******
datasetTest(:, 1) = dati; %Prima colonna che contiene i dati
tabellaLabelTest = readtable(datiLabel); %leggo le label contenenti indicazioni su case e spacecraft
%****Genero due vettori contenenti rispettivamente spacecraft e case
case_field=tabellaLabelTest.Case_';
spacecraft_field=tabellaLabelTest.Spacecraft_';
%****Inserisco nella struttura anche le informazioni appena ricavate****
datasetTest(:, 2) = num2cell(case_field);
datasetTest(:, 3) = num2cell(spacecraft_field);
%****Converto e formatto il dataset di test ****
datasetFinaleTest = cell2table(datasetTest);
datasetFinaleTest = renamevars(datasetFinaleTest,["datasetTest1","datasetTest2","datasetTest3"],["Case","Case_Name","Spacecraft"]);