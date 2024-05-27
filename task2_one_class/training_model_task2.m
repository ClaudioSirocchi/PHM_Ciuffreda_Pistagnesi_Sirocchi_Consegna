import one_class_classification.*

numWindow = 3;

maggioranza = 2;

% Rimozione delle colonne non necessarie dalle tabelle trainTable e testTable
if ismember('EnsembleID_', trainTable.Properties.VariableNames)
    trainTable = removevars(trainTable,["EnsembleID_"]);
    testTable = removevars(testTable,["EnsembleID_"]);
end
if ismember('Task2', trainTable.Properties.VariableNames)
    trainTable = removevars(trainTable,["Task2"]);
    testTable = removevars(testTable,["Task2"]);
end
if ismember('FRM_1/TimeStart', trainTable.Properties.VariableNames)
    trainTable = removevars(trainTable,["FRM_1/TimeStart"]);
    testTable = removevars(testTable,["FRM_1/TimeStart"]);
end
if ismember('FRM_1/TimeEnd', trainTable.Properties.VariableNames)
    trainTable = removevars(trainTable,["FRM_1/TimeEnd"]);
    testTable = removevars(testTable,["FRM_1/TimeEnd"]);
end


% Addestramento del modello One-Class SVM
[Mdl,~,~] = ocsvm(trainTable,StandardizeData=true, KernelScale="auto");

% Valutazione del modello sui dati di test
[tf_test,s_test] = isanomaly(Mdl,testTable);

% Classificazione delle finestre come anomalie o non anomalie
pred = [];
for i = 1:numWindow:length(tf_test)-numWindow+1
    anomalies = sum(tf_test(i:i+numWindow-1) == 1);
    if anomalies>=maggioranza
        pred = [pred, 1]; % La finestra è classificata come anomalia
    else
        pred = [pred, 0]; % La finestra è classificata come non anomalia
    end
end

% Visualizzazione dell'istogramma delle anomalie
histogram(s_test)
xline(Mdl.ScoreThreshold,"r-",["Threshold" Mdl.ScoreThreshold])

% Separazione dei membri non sconosciuti e sconosciuti
notUnknownMembers = testTable;
unknownMembers = array2table([]); % Tabella vuota per i membri sconosciuti
indexToRemove = find(pred == 1); % Indici delle finestre classificate come anomalie

% Se ci sono finestre classificate come anomalie
if isempty(indexToRemove) == 0
    % Rimozione dei membri sconosciuti dalle finestre classificate come anomalie
    for i = flip(indexToRemove)
        unknownMembers = [unknownMembers; testTable((i-1)*numWindow+1:i*numWindow,:)];
        notUnknownMembers((i-1)*numWindow+1:i*numWindow,:) = [];
    end
end

% Salvataggio del modello addestrato
save('testing/trained_Model/trainedModel_task2_oneclass.mat', 'Mdl');