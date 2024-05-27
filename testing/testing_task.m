% **** Funzione per la gestione del voting a magioranza per    ****
% ****                   i diversi task                        ****

function [classes, prediction] = testing_task(numWindow, testTable, trainedModel)
if class(trainedModel) ~= "OneClassSVM"
    [yfit,~]=trainedModel.predictFcn(testTable);
    len = length(yfit);
end
prediction = [];

if ismember('Task1', testTable.Properties.VariableNames)
    majorityThreshold = 2;  
    majorityCount = int32(numWindow * majorityThreshold / 3); 
    
    for i = 1:numWindow:len-numWindow+1
        countOfOnes = sum(yfit(i:i+numWindow-1) == categorical(1));
        if countOfOnes >= majorityCount
            prediction = [prediction, 1];
        else
            prediction = [prediction, 0];
        end
    end

    count_normal = sum(prediction == 0);   
    count_abnormal = sum(prediction == 1);

    wheels = [count_normal, count_abnormal];
    names = ["Class 0", "Class 1"];

    classes = dictionary(names, wheels);
    
elseif (ismember('Task2', testTable.Properties.VariableNames) && class(trainedModel) == "OneClassSVM")
    [tf_test,~] = isanomaly(trainedModel,testTable);

    for i = 1:numWindow:length(tf_test)-numWindow+1
        anomalies = sum(tf_test(i:i+numWindow-1) == 1);
        if anomalies>=1
            prediction = [prediction, 1];
        else
            prediction = [prediction, 0];
        end
    end
    
    wheels = [length(prediction(prediction == 0)) length(prediction(prediction == 1))];
    names = ["Class 0" "Class 1"];
    classes = dictionary(names,wheels);


 elseif ismember('Task2', testTable.Properties.VariableNames)
     majorityThreshold = 2;  
     [yfit,scores]=trainedModel.predictFcn(testTable);
 
     for i = 1:numWindow:len-numWindow+1
         countOfTwo = sum(yfit(i:i+numWindow-1) == 2);
         countOfThree = numWindow-countOfTwo;
         if countOfTwo>=majorityThreshold
             prediction = [prediction, 2];
         else
             prediction = [prediction, 3];
         end
     end
     wheels = [length(prediction(prediction == 2)) length(prediction(prediction == 3))];
     names = ["Class 2" "Class 3"];
 
     classes = dictionary(names,wheels);

   elseif ismember('Task3', testTable.Properties.VariableNames)
        for i = 1:numWindow:len-numWindow+1
            countOfOnes = sum(yfit(i:i+numWindow-1) == 1);
            countOfTwos = sum(yfit(i:i+numWindow-1) == 2);
            countOfThree = sum(yfit(i:i+numWindow-1) == 3);
            countOfFour = sum(yfit(i:i+numWindow-1) == 4);
            countOfFive = sum(yfit(i:i+numWindow-1) == 5);
            countOfSix = sum(yfit(i:i+numWindow-1) == 6);
            countOfSeven = sum(yfit(i:i+numWindow-1) == 7);
            countOfEight = sum(yfit(i:i+numWindow-1) == 8);
        
            count = [countOfOnes; countOfTwos; countOfThree; countOfFour; countOfFive; countOfSix; countOfSeven; countOfEight];
            [M, I] = max(count);
            prediction = [prediction, I];
    
        end
        classes = [];

   elseif ismember('Task4', testTable.Properties.VariableNames)
        for i = 1:numWindow:len-numWindow+1
            countOfOnes = sum(yfit(i:i+numWindow-1) == 1);
            countOfTwos = sum(yfit(i:i+numWindow-1) == 2);
            countOfThree = sum(yfit(i:i+numWindow-1) == 3);
            countOfFour = sum(yfit(i:i+numWindow-1) == 4);
        
            count = [countOfOnes; countOfTwos; countOfThree; countOfFour];
            [M, I] = max(count);
            prediction = [prediction, I];
    
        end
        classes = [];
end 
