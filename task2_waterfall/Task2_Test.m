import featurefunction_2.*
%load("../Progetto_Manutenzione/models.mat") oppure carica manualmente
%oppure genera da ../tsk2_waterfall/Task2_Classification
% Carica i dati di test e calcola le feature, da caricare le feature
% direttamente, quelle estratte dai dati estratti dal task 1
[testFeatureTable2, signal_task2] = featurefunction_2(datasetFinaleTest);

% Inizializza una matrice per memorizzare le previsioni di classe
predictions = ones(size(testFeatureTable2, 1), 1);

% Classificazione con il modello per la classe 2
model_2 = models.Class_2;
class_2_predictions = predict(model_2, testFeatureTable2);

% Sovrascrivi le previsioni con 2 per i dati classificati come classe 2
predictions(class_2_predictions == 1) = 2;

% Rimuovi i dati classificati come classe 2
testFeatureTable2 = testFeatureTable2(class_2_predictions ~= 1, :);

% Classificazione con il modello per la classe 3
model_3 = models.Class_3;
class_3_predictions = predict(model_3, testFeatureTable2);

% Sovrascrivi le previsioni con 3 per i dati classificati come classe 3
predictions(class_3_predictions == 1) = 3;

% Rimuovi i dati classificati come classe 3

% Visualizza le previsioni
disp(predictions);

%regola della maggioranza
numResults = length(predictions);
groupedResults = zeros(numResults/3, 1);


for i = 1:3:numResults
    % Estrai i risultati nella finestra mobile di dimensione 3
    window = predictions(i:i+2);
    
    % Conta quanti 0 e quanti 1 ci sono nella finestra
    countZeros = sum(window == 0);
    countOnes = sum(window == 1);
    counTwo = sum(window == 2);
    countThree = sum(window == 3);
    
    % Applica la regola della maggioranza
    if countZeros >= 2
        groupedResults((i+2)/3) = 0;
    elseif countOnes >= 2
        groupedResults((i+2)/3) = 1;
    elseif counTwo >= 2
        groupedResults((i+2)/3) = 2;
    elseif countThree >= 2
        groupedResults((i+2)/3) = 3;
    else
        % In caso di parità o mancanza di un voto prevalente,
        % assegniamo il valore centrale
        groupedResults((i+2)/3) = results(i+1);
    end
end
disp(groupedResults)
indici_zeri = datasetFinaleTest.ResultModelTaks1 == 0;

for i = 1:length(indici_zeri)
    % Ottieni l'indice corrente
    indice_corrente = i;
    if indici_zeri(i) == 1
        % Sostituisci il valore di ResultModelTaks2 alla riga corrente con 0
        datasetFinaleTest.ResultModelTaks2(indice_corrente) = 0;
    else
        datasetFinaleTest.ResultModelTaks2(indice_corrente) = groupedResults(indice_corrente);
    end
end

datasetFinaleTest.RealTask2 = tabellaLabelTestResult.task2;
ConfT2 = confusionmat(datasetFinaleTest.RealTask2, datasetFinaleTest.ResultModelTaks2);
accuracy = sum(diag(ConfT2)) / sum(ConfT2(:));
confusionchart(ConfT2)
display(accuracy)