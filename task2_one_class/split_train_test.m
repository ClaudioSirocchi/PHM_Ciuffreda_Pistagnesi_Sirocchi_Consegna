load("task2_one_class\FeatureTable1.mat")
% Definizione della percentuale di dati da utilizzare per il test
testPercentage = 20;

% Definizione del numero di finestre
numWindow = 3;

% Copia della tabella delle caratteristiche in trainTable
features = FeatureTable1;
trainTable = FeatureTable1;

% Calcolo della percentuale dei dati di test per i guasti
faultTestPercentage = int32(48*testPercentage/100);

% Calcolo della percentuale dei dati di test per le anomalie
anomalyTestPercentage = int32(24*testPercentage/100);

% Selezione dei dati di test per le anomalie dalla tabella delle caratteristiche
anomalyTest = trainTable(48*numWindow+1:(anomalyTestPercentage+48)*numWindow,:);

% Rimozione dei dati di test per le anomalie dalla tabella delle caratteristiche
trainTable(48*numWindow+1:(anomalyTestPercentage+48)*numWindow,:) = [];

% Selezione dei dati di test per i guasti dalla tabella delle caratteristiche
faultTest = trainTable(1:faultTestPercentage*numWindow,:);

% Rimozione dei dati di test per i guasti dalla tabella delle caratteristiche
trainTable(1:faultTestPercentage*numWindow,:) = [];

% Unione dei dati di test per i guasti e le anomalie in una singola tabella testTable
testTable = [faultTest; anomalyTest];
