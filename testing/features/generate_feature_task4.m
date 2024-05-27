function [featureTable,outputTable] = diagnosticFeatures(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A table or a cell array of tables/matrices containing the
%  data as those imported into the app.
%
% Output:
%  featureTable: A table containing all features and condition variables.
%  outputTable: A table containing the computation results.
%
% This function computes spectra:
%  Case_ps_2/SpectrumData
%
% This function computes features:
%  Case_sigstats/ClearanceFactor
%  Case_sigstats/CrestFactor
%  Case_sigstats/ImpulseFactor
%  Case_sigstats/Kurtosis
%  Case_sigstats/Mean
%  Case_sigstats/PeakValue
%  Case_sigstats/ShapeFactor
%  Case_sigstats/Skewness
%  Case_sigstats/Std
%  Case_sigstats_1/Mean
%  Case_sigstats_1/RMS
%  Case_sigstats_1/ShapeFactor
%  Case_sigstats_1/Skewness
%  Case_sigstats_1/Std
%  Case_sigstats_2/Mean
%  Case_sigstats_2/ShapeFactor
%  Case_sigstats_2/Std
%  Case_sigstats_3/Skewness
%  Case_sigstats_4/Mean
%  Case_sigstats_4/ShapeFactor
%  Case_sigstats_4/Skewness
%  Case_sigstats_4/Std
%  Case_sigstats_5/Mean
%  Case_sigstats_5/Std
%  Case_sigstats_6/ClearanceFactor
%  Case_sigstats_6/CrestFactor
%  Case_sigstats_6/ImpulseFactor
%  Case_sigstats_6/Mean
%  Case_sigstats_6/PeakValue
%  Case_ps_2_spec/BandPower
%
% Frame Policy:
%  Frame name: FRM_1
%  Frame size: 0.4 seconds
%  Frame rate: 0.4 seconds
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 08-May-2024 14:49:11

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Case",'ConditionVariables',"Task4");

% Reset the ensemble to read from the beginning of the ensemble.
reset(outputEnsemble);

% Append new frame policy name to DataVariables.
outputEnsemble.DataVariables = [outputEnsemble.DataVariables;"FRM_1"];

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = "Case";

% Loop through all ensemble members to read and write data.
while hasdata(outputEnsemble)
    % Read one member.
    member = read(outputEnsemble);

    % Read signals.
    Case_full = readMemberData(member,"Case",["TIME","P3","P1","P2","P4","P5","P6","P7"]);

    % Get the frame intervals.
    lowerBound = Case_full.TIME(1);
    upperBound = Case_full.TIME(end);
    fullIntervals = frameintervals([lowerBound upperBound],0.4,0.4,'FrameUnit',"seconds");
    intervals = fullIntervals;

    % Initialize a table to store frame results.
    frames = table;

    % Loop through all frame intervals and compute results.
    for ct = 1:height(intervals)
        % Get all input variables.
        Case = Case_full(Case_full.TIME>=intervals{ct,1}&Case_full.TIME<intervals{ct,2},:);

        % Initialize a table to store results for one frame interval.
        frame = intervals(ct,:);

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P3;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,4,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_2 = ps;
        catch
            Case_ps_2 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2},'VariableNames',{'Case_ps_2'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P1;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,ShapeFactor,Skewness,Std];

            % Package computed features into a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','ShapeFactor','Skewness','Std'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,9);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','ShapeFactor','Skewness','Std'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats},'VariableNames',{'Case_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P2;
            Mean = mean(inputSignal,'omitnan');
            RMS = rms(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [Mean,RMS,ShapeFactor,Skewness,Std];

            % Package computed features into a table.
            featureNames = {'Mean','RMS','ShapeFactor','Skewness','Std'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,5);
            featureNames = {'Mean','RMS','ShapeFactor','Skewness','Std'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_1},'VariableNames',{'Case_sigstats_1'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P3;
            Mean = mean(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [Mean,ShapeFactor,Std];

            % Package computed features into a table.
            featureNames = {'Mean','ShapeFactor','Std'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,3);
            featureNames = {'Mean','ShapeFactor','Std'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_2},'VariableNames',{'Case_sigstats_2'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P4;
            Skewness = skewness(inputSignal);

            % Concatenate signal features.
            featureValues = Skewness;

            % Package computed features into a table.
            featureNames = {'Skewness'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,1);
            featureNames = {'Skewness'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_3},'VariableNames',{'Case_sigstats_3'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P5;
            Mean = mean(inputSignal,'omitnan');
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [Mean,ShapeFactor,Skewness,Std];

            % Package computed features into a table.
            featureNames = {'Mean','ShapeFactor','Skewness','Std'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,4);
            featureNames = {'Mean','ShapeFactor','Skewness','Std'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_4},'VariableNames',{'Case_sigstats_4'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P6;
            Mean = mean(inputSignal,'omitnan');
            Std = std(inputSignal,'omitnan');

            % Concatenate signal features.
            featureValues = [Mean,Std];

            % Package computed features into a table.
            featureNames = {'Mean','Std'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,2);
            featureNames = {'Mean','Std'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_5},'VariableNames',{'Case_sigstats_5'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P7;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Mean,PeakValue];

            % Package computed features into a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Mean','PeakValue'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,5);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Mean','PeakValue'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_6},'VariableNames',{'Case_sigstats_6'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_2.SpectrumData;
            w = Case_ps_2.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0) & (w<=factor*10);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = BandPower;

            % Package computed features into a table.
            featureNames = {'BandPower'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Package computed features into a table.
            featureValues = NaN(1,1);
            featureNames = {'BandPower'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2_spec},'VariableNames',{'Case_ps_2_spec'})];

        %% Concatenate frames.
        frames = [frames;frame]; %#ok<*AGROW>
    end

    % Write all the results for the current member to the ensemble.
    memberResult = table({frames},'VariableNames',"FRM_1");
    writeToLastMemberRead(outputEnsemble,memberResult)
end

% Gather all features into a table.
selectedFeatureNames = ["FRM_1/Case_sigstats/ClearanceFactor","FRM_1/Case_sigstats/CrestFactor","FRM_1/Case_sigstats/ImpulseFactor","FRM_1/Case_sigstats/Kurtosis","FRM_1/Case_sigstats/Mean","FRM_1/Case_sigstats/PeakValue","FRM_1/Case_sigstats/ShapeFactor","FRM_1/Case_sigstats/Skewness","FRM_1/Case_sigstats/Std","FRM_1/Case_sigstats_1/Mean","FRM_1/Case_sigstats_1/RMS","FRM_1/Case_sigstats_1/ShapeFactor","FRM_1/Case_sigstats_1/Skewness","FRM_1/Case_sigstats_1/Std","FRM_1/Case_sigstats_2/Mean","FRM_1/Case_sigstats_2/ShapeFactor","FRM_1/Case_sigstats_2/Std","FRM_1/Case_sigstats_3/Skewness","FRM_1/Case_sigstats_4/Mean","FRM_1/Case_sigstats_4/ShapeFactor","FRM_1/Case_sigstats_4/Skewness","FRM_1/Case_sigstats_4/Std","FRM_1/Case_sigstats_5/Mean","FRM_1/Case_sigstats_5/Std","FRM_1/Case_sigstats_6/ClearanceFactor","FRM_1/Case_sigstats_6/CrestFactor","FRM_1/Case_sigstats_6/ImpulseFactor","FRM_1/Case_sigstats_6/Mean","FRM_1/Case_sigstats_6/PeakValue","FRM_1/Case_ps_2_spec/BandPower"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
outputTable = readall(outputEnsemble);

end
