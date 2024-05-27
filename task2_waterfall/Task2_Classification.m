% Carica i dati di addestramento
loader = load('task2_waterfall/feature_dataset_task2.mat');
FilteredFT = loader.FeatureTable1;

% Rimuovi le righe della classe 0
FilteredFT = FilteredFT(FilteredFT.Task2 ~= 0, :);

% Classificatore
classi = unique(FilteredFT.Task2);
models = struct(); % Inizializza la struttura per memorizzare i modelli
trueLabels = FilteredFT.Task2;
predictedLabels = zeros(size(FilteredFT, 1), 1); % Inizializza le etichette predette

for i = 1:length(classi)
    currentClass = classi(i);
    
    % Creazione di un task di classificazione binaria: classe corrente vs. tutte le altre classi
    y = double(FilteredFT.Task2 == currentClass);  % Converti in double per evitare problemi
    
    % Rimuovi la seconda colonna, che contiene l'etichetta di classe, dalle feature
    X = FilteredFT;
    X(:, 2) = [];
    X(:, 1) = [];
    
    % Addestramento del modello LDA
    model = fitcdiscr(X, y, 'DiscrimType', 'pseudolinear'); % 'pseudolinear' per dati non normalmente distribuiti
    
    % Memorizzazione del modello per la classe corrente
    fieldName = strcat('Class_', num2str(currentClass));
    models.(fieldName) = model;
    
    % Valutazione del modello (facoltativa)
    cv = crossval(model, 'KFold', 5); % Utilizza 5 fold cross-validation
    mcr = kfoldLoss(cv); % Calcola il tasso di errore di classificazione medio
    disp(['Misclassification rate for Class ', num2str(currentClass), ': ', num2str(mcr)]);
    
    % Predizione delle etichette per i dati di addestramento
    predictions = predict(model, X);
    
    % Aggiornamento delle etichette predette
    predictedLabels(predictions == 1) = currentClass;
end

% Visualizza la matrice di confusione complessiva
confMat = confusionmat(trueLabels, predictedLabels);
disp('Confusion Matrix:');
disp(confMat);
confusionchart(confMat);