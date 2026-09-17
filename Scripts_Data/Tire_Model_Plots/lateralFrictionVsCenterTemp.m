%% Lateral friction versus tire center temperature from TIRF data
function analysis = lateralFrictionVsCenterTemp(dataFiles)
%LATERALFRICTIONVSCENTERTEMP Analyze peak lateral friction versus TSTC.
%   analysis = lateralFrictionVsCenterTemp() imports the two configured
%   cornering-data files, plots every valid instantaneous lateral friction
%   sample, extracts the peak of each slip-angle sweep, and plots an
%   operating-condition-normalized temperature trend.
%
%   The normalized analysis compares points only within matching run,
%   load, camber, and pressure bins. This reduces the risk of mistaking a
%   change in test condition for a temperature effect.

if nargin < 1 || isempty(dataFiles)
    dataFolder = ...
        "/Users/andrei/Desktop/FSAE/Tire Fitting/" + ...
        "Hoosier 20.5x7-13 R20 7'' rim/Round 9 Cornering Data";
    dataFiles = fullfile(dataFolder, ["B2356run17.dat"; "B2356run18.dat"]);
end

dataFiles = string(dataFiles(:));
if isempty(dataFiles) || any(~isfile(dataFiles))
    error('lateralFrictionVsCenterTemp:FileNotFound', ...
        'Every input data file must exist.');
end

% Analysis settings
muSmoothingSamples = 21;       % 0.21 s at the recorded 100 Hz sample rate
minimumPeakSeparationS = 2;    % Avoid multiple detections in one force peak
minimumPeakProminence = 0.15;
minimumSlipAngleDeg = 1;
minimumLoadN = 250;
minimumSpeedKph = 30;
maximumAbsoluteSlipRatio = 0.1;
minimumPeaksPerCondition = 3;
temperatureBinWidthC = 2;
highPerformanceFraction = 0.98; % Within 2% of the best normalized bin

peakTables = cell(numel(dataFiles),1);
sampleTables = cell(numel(dataFiles),1);
requiredVariables = ["ET","V","SA","IA","P","FY","FZ", ...
    "NFY","TSTC","SR"];

for fileIndex = 1:numel(dataFiles)
    opts = detectImportOptions(dataFiles(fileIndex), ...
        FileType="text", Delimiter="\t", VariableNamingRule="preserve");
    opts.VariableNamesLine = 2;
    opts.DataLines = [4 Inf];
    tireData = readtable(dataFiles(fileIndex), opts);

    missingVariables = setdiff(requiredVariables, ...
        string(tireData.Properties.VariableNames));
    if ~isempty(missingVariables)
        error('lateralFrictionVsCenterTemp:MissingVariables', ...
            'File %s is missing variables: %s.', dataFiles(fileIndex), ...
            strjoin(missingVariables, ', '));
    end

    % NFY is the recorded normalized lateral force. Smooth only for robust
    % peak detection; all metadata are taken from the corresponding sample.
    smoothedMuY = smoothdata(abs(tireData.NFY), ...
        'movmean', muSmoothingSamples);
    peakMask = islocalmax(smoothedMuY, ...
        SamplePoints=tireData.ET, ...
        MinSeparation=minimumPeakSeparationS, ...
        MinProminence=minimumPeakProminence);

    peakMask = peakMask & ...
        abs(tireData.SA) >= minimumSlipAngleDeg & ...
        abs(tireData.FZ) >= minimumLoadN & ...
        tireData.V >= minimumSpeedKph & ...
        abs(tireData.SR) <= maximumAbsoluteSlipRatio;

    [~,runName] = fileparts(dataFiles(fileIndex));

    % Keep all physically relevant moving-tire samples for the raw cloud.
    % Unlike peakMask, this deliberately includes near-zero slip angles.
    sampleMask = ...
        abs(tireData.FZ) >= minimumLoadN & ...
        tireData.V >= minimumSpeedKph & ...
        abs(tireData.SR) <= maximumAbsoluteSlipRatio & ...
        isfinite(tireData.TSTC) & isfinite(tireData.NFY);
    nSamples = nnz(sampleMask);
    sampleTables{fileIndex} = table( ...
        repmat(runName,nSamples,1), ...
        tireData.TSTC(sampleMask), ...
        tireData.NFY(sampleMask), ...
        abs(tireData.FZ(sampleMask)), ...
        tireData.IA(sampleMask), ...
        tireData.P(sampleMask), ...
        'VariableNames', {'Run','CenterTempC','MuY', ...
        'LoadN','CamberDeg','PressureKPa'});

    nPeaks = nnz(peakMask);
    peakTables{fileIndex} = table( ...
        repmat(runName,nPeaks,1), ...
        tireData.ET(peakMask), ...
        tireData.TSTC(peakMask), ...
        smoothedMuY(peakMask), ...
        tireData.SA(peakMask), ...
        abs(tireData.FZ(peakMask)), ...
        tireData.IA(peakMask), ...
        tireData.P(peakMask), ...
        'VariableNames', {'Run','TimeS','CenterTempC','PeakMuY', ...
        'SlipAngleDeg','LoadN','CamberDeg','PressureKPa'});
end

allSamples = vertcat(sampleTables{:});
peaks = vertcat(peakTables{:});
if isempty(peaks)
    error('lateralFrictionVsCenterTemp:NoPeaks', ...
        'No valid cornering peaks were detected with the current settings.');
end

% Bin test conditions so temperature is compared within approximately
% equivalent load, camber, and pressure operating points.
peaks.LoadBinN = round(peaks.LoadN/100)*100;
peaks.CamberBinDeg = round(peaks.CamberDeg*2)/2;
peaks.PressureBinKPa = round(peaks.PressureKPa/5)*5;

conditionVariables = ["Run","LoadBinN","CamberBinDeg","PressureBinKPa"];
[conditionId,~] = findgroups(peaks(:,conditionVariables));
conditionCounts = splitapply(@numel,peaks.PeakMuY,conditionId);
hasRepeatedCondition = conditionCounts(conditionId) >= ...
    minimumPeaksPerCondition;
comparablePeaks = peaks(hasRepeatedCondition,:);

if isempty(comparablePeaks)
    error('lateralFrictionVsCenterTemp:NoRepeatedConditions', ...
        'No operating condition contains enough repeated peaks.');
end

[conditionId,~] = findgroups(comparablePeaks(:,conditionVariables));
referenceMu = splitapply( ...
    @(x) mean(maxk(x,min(2,numel(x)))), ...
    comparablePeaks.PeakMuY, conditionId);
comparablePeaks.RelativeMuY = comparablePeaks.PeakMuY ./ ...
    referenceMu(conditionId);

firstEdge = floor(min(comparablePeaks.CenterTempC)/temperatureBinWidthC) * ...
    temperatureBinWidthC;
lastEdge = ceil(max(comparablePeaks.CenterTempC)/temperatureBinWidthC) * ...
    temperatureBinWidthC;
temperatureEdges = firstEdge:temperatureBinWidthC:lastEdge;
if numel(temperatureEdges) < 2
    temperatureEdges = firstEdge + [0 temperatureBinWidthC];
end

comparablePeaks.TempBin = discretize( ...
    comparablePeaks.CenterTempC, temperatureEdges);
binnedTrend = groupsummary(comparablePeaks, 'TempBin', ...
    ["median","mean","std"], 'RelativeMuY');
temperatureCenters = (temperatureEdges(1:end-1) + ...
    temperatureEdges(2:end))/2;
binnedTrend.CenterTempC = temperatureCenters(binnedTrend.TempBin).';
binnedTrend = binnedTrend(binnedTrend.GroupCount >= 3,:);
binnedTrend = sortrows(binnedTrend, 'CenterTempC');

if isempty(binnedTrend)
    error('lateralFrictionVsCenterTemp:InsufficientTemperatureBins', ...
        'Not enough repeated peaks exist in any temperature bin.');
end

% Find the contiguous high-performance band around the best median bin.
[bestRelativeMu,bestIndex] = max(binnedTrend.median_RelativeMuY);
isHighPerformance = binnedTrend.median_RelativeMuY >= ...
    highPerformanceFraction * bestRelativeMu;
lowerIndex = bestIndex;
while lowerIndex > 1 && isHighPerformance(lowerIndex-1) && ...
        binnedTrend.CenterTempC(lowerIndex) - ...
        binnedTrend.CenterTempC(lowerIndex-1) <= 1.01*temperatureBinWidthC
    lowerIndex = lowerIndex - 1;
end
upperIndex = bestIndex;
while upperIndex < height(binnedTrend) && isHighPerformance(upperIndex+1) && ...
        binnedTrend.CenterTempC(upperIndex+1) - ...
        binnedTrend.CenterTempC(upperIndex) <= 1.01*temperatureBinWidthC
    upperIndex = upperIndex + 1;
end

estimatedRangeC = [ ...
    binnedTrend.CenterTempC(lowerIndex) - temperatureBinWidthC/2, ...
    binnedTrend.CenterTempC(upperIndex) + temperatureBinWidthC/2];

% Plot all instantaneous friction samples and the normalized peak trend.
figure('Color','w','Name','Lateral friction versus tire center temperature');
layout = tiledlayout(1,1,TileSpacing='compact',Padding='compact');

rawAxes = nexttile(layout);
hold(rawAxes,'on');
scatter(rawAxes,allSamples.CenterTempC,allSamples.MuY,6, ...
    [0.20 0.45 0.75],'filled',MarkerFaceAlpha=0.12, ...
    MarkerEdgeAlpha=0.12);
rawYLimits = ylim(rawAxes);
rawTemperatureBand = patch(rawAxes, ...
    [estimatedRangeC(1) estimatedRangeC(2) estimatedRangeC(2) estimatedRangeC(1)], ...
    [rawYLimits(1) rawYLimits(1) rawYLimits(2) rawYLimits(2)], ...
    [0.70 0.88 0.70],FaceAlpha=0.28,EdgeColor='none', ...
    HandleVisibility='off');
uistack(rawTemperatureBand,'bottom');
grid(rawAxes,'on');
box(rawAxes,'on');
xlabel(rawAxes,'Tire center temperature TSTC [deg C]');
ylabel(rawAxes,'Lateral Friction Coef. Fy/Fz [-]');
title(rawAxes,'Lateral Friction Coef. vs Temperature');


analysis = struct;
analysis.AllSamples = allSamples;
analysis.Peaks = peaks;
analysis.ComparablePeaks = comparablePeaks;
analysis.BinnedTrend = binnedTrend;
analysis.EstimatedHighPerformanceRangeC = estimatedRangeC;
analysis.HighPerformanceFraction = highPerformanceFraction;

fprintf(['Plotted %d instantaneous samples. Detected %d lateral-force ' ...
    'peaks; %d were retained in repeated condition groups.\n'], ...
    height(allSamples),height(peaks),height(comparablePeaks));
fprintf('Estimated >= %.0f%% high-performance center-temperature range: %.1f to %.1f deg C.\n', ...
    100*highPerformanceFraction,estimatedRangeC(1),estimatedRangeC(2));
end
