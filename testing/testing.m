clearvars;
close all;
clc;
clear all;

addpath('features/');
addpath('trained_Model/');
% **** Caricamento dei dati ****
run("../DatasetStrutturato.m")
run("../CaricamentoTest.m")
% **** Import delle funzioni di elabolarione ****
import testing_task.*
import generate_feature_task1.*
import generate_feature_task2_oneclass.*
import generate_feature_task2_binario.*
import generate_feature_task2_waterfall.*
import generate_feature_task3.*
import generate_feature_task4.*
import generate_feature_task5.*

% **** Caricamento dei modelli nel workspace ****
load('trainedModel_task1.mat')
load('trainedModel_task2_oneclass.mat')
load('trainedModel_task2_binario.mat')
load('trainedModel_task2_waterfall.mat')
load('trainedModel_task3.mat')
load('trainedModel_task4.mat')
load('trainedModel_task5.mat')

% **** Configurazione delle cartelle *****
trainPath = '../dataset/train/data/';
labelsPath = '../dataset/train/labels.xlsx';
testPath = '../dataset/test/data/';
answers = '../dataset/answer.csv';
answers = readtable(answers, 'VariableNamingRule', 'preserve');


%% task 1, dati normali e anormali
% **** Generazione delle feature dei dati di test del task 1 ****
[testFeatureTable1, x1] = generate_feature_task1(datasetFinaleTest); 
% **** Test dei dati con il modello ****
[count1, prediction1] = testing_task(3, testFeatureTable1, trainedModel); 
fprintf('Dati classificati come comportamento normale (classe 0): %d \n', count1("Class 0"));
fprintf('Dati classificati come comportamento anormale (classe 1): %d \n', count1("Class 1"));

% **** Calcolo delle predizioni corrette e dell'accuracy ****
correctPredictions = (answers.task1' == prediction1);
accuracy = mean(correctPredictions) * 100;
disp(['Accuracy: ', num2str(accuracy), '%']);

% **** Rendering Confusion Matrix ****
classLabels = {'Normale', 'Anormale'};
C = confusionmat(answers.task1', prediction1);
figure;
confusionchart(C, classLabels);
title(['Totale Accuracy Task 1: ', num2str(accuracy), ' %']);
fig_name = 'image/confusionchart_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% **** Aggiunta id alle predizioni e traspone 'prediction1' ****
prediction1 = [answers.ID prediction1'];

%% task 2, guasti sconosciuti
idx = prediction1(:,2)==1;
testDataTask2 = [datasetFinaleTest(prediction1(:,2)==1,:) table(prediction1(idx,1))];
[testFeatureTable2Unknown] = generate_feature_task2_oneclass(testDataTask2(:,1));
[count2Unknown, prediction2Unknown] = testing_task(3, testFeatureTable2Unknown, Mdl);
fprintf('Dati classificati come guasti conosciuti (classe 0): %d \n', count2Unknown("Class 0"));
fprintf('Dati classificati come guasti sconosciuti (classe 1): %d \n', count2Unknown("Class 1"));

testDataTask2 = renamevars(testDataTask2,["Case_Name"],["ID"]);
prediction2Unknown = [testDataTask2(:,2) table(prediction2Unknown')];

task2ActualUnknown = array2table([answers.ID, answers.task2]);
task2ActualUnknown = renamevars(task2ActualUnknown,["Var1", "Var2"],["ID", "Task2"]);
[commonIDs, ~, ~] = intersect(task2ActualUnknown.ID, prediction2Unknown.ID);

task2ActualUnknown(~(ismember(task2ActualUnknown.ID, commonIDs)), :) = [];
idx = find(task2ActualUnknown.Task2 ~= 1);
task2ActualUnknown.Task2(idx) = 0;


%% task 2, guasti conosciuti
idx = table2array(prediction2Unknown(:,2))==0;
testDataTask2 = [testDataTask2(idx,1) prediction2Unknown(idx,1)];
[testFeatureTable2] = generate_feature_task2_binario(testDataTask2(:,1));
[count2, prediction2] = testing_task(3, testFeatureTable2, trainedModel_task2_binario);
 fprintf('Dati classificati come anomalia di bolla (classe 2): %d \n', count2("Class 2"));
 fprintf('Dati classificati come anomalia della valvola (classe 3): %d \n', count2("Class 3"));

prediction2 = [testDataTask2(:,2) table(prediction2')];
prediction1 = array2table(prediction1);
prediction1 = renamevars(prediction1,["prediction11", "prediction12"],["ID", "Var1"]);

task2Prediction = prediction1;
[commonIDs, locTable1, locTable2] = intersect(task2Prediction.ID, prediction2.ID);
task2Prediction.Var1(locTable1) = prediction2.Var1(locTable2);
task2Actual = answers.task2';
correctPredictions = task2Actual' == task2Prediction.Var1;

% **** Calcolo delle predizioni corrette e dell'accuracy ****
accuracy2 = sum(correctPredictions) / numel(task2Actual);
disp(['Accuracy: ', num2str(accuracy2 * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels2 = {'Normal', 'Unknown', 'Bubble Anomaly', 'Valve'};
C2 = confusionmat(task2Actual,task2Prediction.Var1);
figure;
subplot(1,2,1);
confusionchart(C2, classLabels2);
sgtitle('Testing - Task 2', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Totale Accuracy Task 2 cascata: ', num2str(accuracy2*100), ' %']);

%% accuracy task 2 individuale
task2Prediction.Var1(locTable1) = prediction2.Var1(locTable2);
task2Actual = answers.task2';
correctPredictions = task2Actual' == task2Prediction.Var1 ;

% Calcola e visualizza l'accuratezza individuale del classificatore di
% classe 2
task2Actual_bis = task2Actual(task2Prediction.Var1 ~= 0);
task2prediction_bis = task2Prediction.Var1 (task2Prediction.Var1 ~= 0);
correctPredictions_bis = double(task2Actual_bis) == task2prediction_bis';

% **** Calcolo delle predizioni corrette e dell'accuracy ****
accuracy2_bis = sum(correctPredictions_bis) / numel(task2Actual_bis);
disp(['Accuracy individuale Task 2: ', num2str(accuracy2_bis * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels2 = {'Unknown', 'Bubble Anomaly', 'Valve'};
C2 = confusionmat(task2Actual_bis,task2prediction_bis);
subplot(1,2,2);
confusionchart(C2, classLabels2);
title(['Accuracy Task 2: ', num2str(accuracy2_bis*100), ' %']);
fig_name = 'image/confusionchart_task2';
set(gcf, 'Position', [150, 150, 1200, 500]); 
saveas(gcf, [fig_name, '.png']);

%% task 2 custom
%scartato perche meno efficente 
%{

idx_cus = table2array(prediction1(:,2))==1;
testDataTask2cus = [datasetFinaleTest(idx_cus,:) table(prediction1(idx_cus,1))];
[testFeatureTable2, signal_task2] = generate_feature_task2_waterfall(testDataTask2cus(:,1));
predictions = ones(size(testFeatureTable2, 1), 1); %Matrice di memmorizzazione delle predizioni effettuate

% **** Classificazione con il modello per la classe 2 ****
model_2 = models.Class_2;
class_2_predictions = predict(model_2, testFeatureTable2);
predictions(class_2_predictions == 1) = 2; % Sovrascrivi le previsioni con 2 per i dati classificati come classe 2
testFeatureTable2 = testFeatureTable2(class_2_predictions ~= 1, :); % Rimuovi i dati classificati come classe 2

% **** Classificazione con il modello per la classe 3 ****
model_3 = models.Class_3;
class_3_predictions = predict(model_3, testFeatureTable2);
predictions(class_3_predictions == 1) = 3;% Sovrascrivi le previsioni con 3 per i dati classificati come classe 3


% **** Regola della maggioranza per selezionare le scelte ****

% Estraggo i risultati considerando una finestra mobile di dimensione 3, in
% accordo con le politiche applicate in merito alla framepolicy e calcolo nei
% tre valori la maggioranza, ossia quello che si verifica più volte

numResults = length(predictions);
groupedResults = zeros(numResults/3, 1);
for i = 1:3:numResults
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
prediction2_cus = [testDataTask2cus(:,2) array2table(groupedResults)];
prediction2_cus = renamevars(prediction2_cus,["Case_Name", "groupedResults"],["ID", "Var1"]);


[commonIDs, locTable1, locTable2] = intersect(task2Prediction.ID, prediction2_cus.ID);
task2Prediction.Var1(locTable1) = prediction2_cus.Var1(locTable2);

task2Actual_cus = answers.task2';

correctPredictions = task2Actual_cus' == task2Prediction.Var1;

% Calculate accuracy
accuracy2 = sum(correctPredictions) / numel(task2Actual);

% Display accuracy
disp(['Accuracy: ', num2str(accuracy2 * 100), '%']);

classLabels2 = {'Normal', 'Unknown', 'Bubble Anomaly', 'Valve'};

C2 = confusionmat(task2Actual,task2Prediction.Var1);
figure;
confusionchart(C2, classLabels2);
sgtitle(['Totale Accuracy Task 2: ', num2str(accuracy2*100), ' %']);
fig_name = 'image/confusionchart_task2_bis';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);
%}

%% task 3, contaminazione da bolle
testDataTask3 = testDataTask2(prediction2.Var1 == 2, :);
[testFeatureTable3] = generate_feature_task3(testDataTask3(:,1));
[count3, prediction3] = testing_task(3, testFeatureTable3, trainedModel_task3);

% **** Calcolo delle predizioni corrette e dell'accuracy ****
prediction3 = [testDataTask3(:,2) table(prediction3')];
index = prediction1;
index(:,2) = {0};
task3Prediction = index;
[commonIDs, locTable1, locTable2] = intersect(task3Prediction.ID, prediction3.ID);
task3Prediction.Var1(locTable1) = prediction3.Var1(locTable2);
task3Actual = answers.task3';
correctPredictions = task3Actual' == task3Prediction.Var1;
accuracy3 = sum(correctPredictions) / numel(task3Actual);
disp(['Accuracy Task 3 cascata: ', num2str(accuracy3 * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels3 = {'Altri', 'BP1', 'BP2', 'BP3', 'BP4', 'BP5', 'BP6', 'BP7', 'BV1'};
C3 = confusionmat(task3Actual,task3Prediction.Var1);
figure;
subplot(1, 2, 1);
confusionchart(C3, classLabels3);
sgtitle('Testing - Task 3', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Totale Accuracy Task 3 cascata: ', num2str(accuracy3*100), ' %']);

%% accuracy task 3 singolo
task3Prediction.Var1(locTable1) = prediction3.Var1(locTable2);
task3Actual = answers.task3';
correctPredictions = task3Actual' == task3Prediction.Var1;

task3Actual_bis = task3Actual(task3Prediction.Var1 ~= 0);
task3prediction_bis = task3Prediction.Var1 (task3Prediction.Var1 ~= 0);
correctPredictions_bis = double(task3Actual_bis) == task3prediction_bis' ;
accuracy3_bis = sum(correctPredictions_bis) / numel(task3Actual_bis);
disp(['Accuracy Task 3 singolo: ', num2str(accuracy3_bis * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels3 = {'BP1', 'BP2', 'BP3', 'BP4', 'BP5', 'BP6', 'BP7', 'BV1'};
C3 = confusionmat(task3Actual_bis,task3prediction_bis);
subplot(1, 2, 2);
confusionchart(C3, classLabels3);
title(['Accuracy Task 3: ', num2str(accuracy3_bis*100), ' %']);
fig_name = 'image/confusionchart_task3';
set(gcf, 'Position', [150, 150, 1200, 500]); 
saveas(gcf, [fig_name, '.png']);

%% task 4, identificazione della valvola guasta
testDataTask4 = testDataTask2(prediction2.Var1 == 3, :);
[testFeatureTable4] = generate_feature_task4(testDataTask4(:,1));
[count4, prediction4] = testing_task(3, testFeatureTable4, trainedModel_task4);

% **** Calcolo delle predizioni corrette e dell'accuracy ****
prediction4 = [testDataTask4(:,2) table(prediction4')];
index = prediction1;
index(:,2) = {0};
task4Prediction = index;
[commonIDs, locTable1, locTable2] = intersect(task4Prediction.ID, prediction4.ID);
task4Prediction.Var1(locTable1) = prediction4.Var1(locTable2);
task4Actual = answers.task4';
correctPredictions = task4Actual' == task4Prediction.Var1;
accuracy4 = sum(correctPredictions) / numel(task4Actual);
disp(['Accuracy Task 4 cascata: ', num2str(accuracy4 * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels4 = {'Altri', 'SV1', 'SV2', 'SV3', 'SV4'};
C4 = confusionmat(task4Actual,task4Prediction.Var1);
figure;
subplot(1, 2, 1);
confusionchart(C4, classLabels4);
sgtitle('Testing - Task 4', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Totale Accuracy Task 4 cascata: ', num2str(accuracy4*100), ' %']);

%% accuracy task 4 singolo
task4Prediction.Var1(locTable1) = prediction4.Var1(locTable2);
task4Actual = answers.task4';
correctPredictions = task4Actual' == task4Prediction.Var1 ;

task4Actual_bis = task4Actual(task4Prediction.Var1 ~= 0);
task4prediction_bis = task4Prediction.Var1 (task4Prediction.Var1 ~= 0);
correctPredictions_bis = double(task4Actual_bis) == task4prediction_bis' ;
accuracy4_bis = sum(correctPredictions_bis) / numel(task4Actual_bis);
disp(['Accuracy individuale Task 4: ', num2str(accuracy4_bis * 100), '%']);

% **** Rendering Confusion Matrix ****
classLabels4 = { 'SV1', 'SV2', 'SV3', 'SV4'};
C4 = confusionmat(task4Actual_bis,task4prediction_bis);
subplot(1, 2, 2);
confusionchart(C4, classLabels4);
title(['Accuracy Task 4: ', num2str(accuracy4_bis*100), ' %']);
fig_name = 'image/confusionchart_task4';
set(gcf, 'Position', [150, 150, 1200, 500]);
saveas(gcf, [fig_name, '.png']);


%% Task 5, previsione del rapporto di apertura delle valvole guaste
testDataTask5 = testDataTask2(prediction2.Var1 == 3, :);
[testFeatureTable5] = generate_feature_task5(testDataTask5(:,1));

% **** Calcolo delle predizioni corrette e dell'accuracy ****
prediction5 = trainedModel_task5.predictFcn(testFeatureTable5);
numResults = length(prediction5);
for i = 1:3:numResults
    window = prediction5(i:i+2);
    windowMean = mean(window);
    groupedResult5((i+2)/3) = windowMean;
end

prediction5 = [testDataTask5(:,2) table(groupedResult5')];
index = prediction1;
index(:,2) = {0};
task5Prediction = index;
[commonIDs, locTable1, locTable2] = intersect(task5Prediction.ID, prediction5.ID);
task5Prediction.Var1(locTable1) = prediction5.Var1(locTable2);
task5RegPrediction = prediction5;
task5Actual = answers.task5;
task5RegPrediction.TrueValue = double(task5Actual(locTable1));

% **** Calcola metriche per la valutazione della regressione ****
RMSE = sqrt(mean((task5RegPrediction.TrueValue - task5RegPrediction.Var1).^2));
MAE = mean(abs(task5RegPrediction.TrueValue - task5RegPrediction.Var1));
SSres = sum((task5RegPrediction.TrueValue - task5RegPrediction.Var1).^2);
SStot = sum((task5RegPrediction.TrueValue - mean(task5RegPrediction.TrueValue)).^2);
R2 = 1 - (SSres / SStot);

% % **** Rendering Scatter plot  ****
figure;
scatter(task5RegPrediction.TrueValue, task5RegPrediction.Var1, 100, 'filled'); 
hold on;
scatter(task5RegPrediction.TrueValue, task5RegPrediction.TrueValue, 100, 'r', 'filled');
title(sprintf('Confronto Valori Predetti vs Valori Effettivi\nRMSE: %.4f, MAE: %.4f, R²: %.4f', RMSE, MAE, R2));
xlabel('Valori Effettivi');
ylabel('Valori Predetti');
legend('Valori Predetti', 'Valori Effettivi', 'Location', 'best');
grid on;
fig_name = 'image/scatter_plot_task5';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);


%% Metrica di valutazione
predictions = {prediction1(:,1:2), task2Prediction(:,1:2), task3Prediction(:,1:2), task4Prediction(:,1:2), task5Prediction(:,1:2)};

punteggio_predizione=0;
punteggio_massimo= 0;

prediction1 = renamevars(prediction1,["ID", "Var1"], ["ID", "Task1"]);
task2Prediction = renamevars(task2Prediction,["ID", "Var1"], ["ID", "Task2"]);
task3Prediction = renamevars(task3Prediction,["ID", "Var1"], ["ID", "Task3"]);
task4Prediction = renamevars(task4Prediction,["ID", "Var1"], ["ID", "Task4"]);
task5Prediction = renamevars(task5Prediction,["ID", "Var1"], ["ID", "Task5"]);

punteggio_task1 = [answers.("Spacecraft No."), (prediction1.Task1 == answers.task1)];
for i=1:length(punteggio_task1)
    if punteggio_task1(i,2)==1
        if punteggio_task1(i,1)==4        
            punteggio_predizione = punteggio_predizione+20;
        else 
            punteggio_predizione = punteggio_predizione+10;
        end
    end
end


punteggio_task2 = [answers.("Spacecraft No."), (task2Prediction.Task2 == answers.task2)];
for i=1:length(punteggio_task2)
    if table2array(answers(i,"task2")) ~= 0 && punteggio_task2(i,2)==1
        if punteggio_task2(i,1)==4        
            punteggio_predizione = punteggio_predizione+20;
        else 
            punteggio_predizione = punteggio_predizione+10;
        end
    end
end

punteggio_task3 = [answers.("Spacecraft No."), (task3Prediction.Task3 == answers.task3)];
for i=1:length(punteggio_task3)
    if table2array(answers(i,"task3")) ~= 0 && punteggio_task3(i,2)==1
        if punteggio_task3(i,1)==4        
            punteggio_predizione = punteggio_predizione+20;
        else 
            punteggio_predizione = punteggio_predizione+10;
        end
    end
end

punteggio_task4 = [answers.("Spacecraft No."), (task4Prediction.Task4 == answers.task4)];
for i=1:length(punteggio_task4)
    if table2array(answers(i,"task4")) ~= 0 && punteggio_task4(i,2)==1
        if punteggio_task4(i,1)==4        
            punteggio_predizione = punteggio_predizione+20;
        else 
            punteggio_predizione = punteggio_predizione+10;
        end
    end
end

punteggio_task5 = [answers.("Spacecraft No."), task5Prediction.Task5, answers.task5];
for i=1:length(punteggio_task5)
    if punteggio_task5(i,3) ~= 100 
        s = max(-abs(punteggio_task5(i,2)-punteggio_task5(i,3))+20, 0);
        if punteggio_task4(i,1)==4        
            punteggio_predizione = punteggio_predizione+(s*2);
        else 
            punteggio_predizione = punteggio_predizione+s;
        end
    end
end

%% calcolo punteggio massimo ottenibile per ciascun task
%task 1
score_max_task1 = 20 * sum(answers{:, 'Spacecraft No.'} == 4) + ...
                   10 * sum(answers{:, 'Spacecraft No.'} ~= 4);

%task 5
score_max_task5 = 40 * sum(answers{:, end-1} ~= 100 & answers{:, 'Spacecraft No.'} == 4) + ...
                   20 * sum(answers{:, end-1} ~= 100 & answers{:, 'Spacecraft No.'} ~= 4);

%task 2, 3 e 4
score_max_other_tasks = 20 * sum(answers{:, 4:end-2} ~= 0 & answers{:, 'Spacecraft No.'} == 4) + ...
                        10 * sum(answers{:, 4:end-2} ~= 0 & answers{:, 'Spacecraft No.'} ~= 4);

punteggio_massimo = score_max_task1 + sum(score_max_other_tasks) + score_max_task5;

punteggio_predizione = punteggio_predizione/punteggio_massimo*100;
disp(['Punteggio finale ottenuto: ', num2str(punteggio_predizione,'%.2f'),'%']);

