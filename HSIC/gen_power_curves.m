% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')

% Experiment parameters.
sampleSizes = 10:10:200;
alpha=0.05;
numShuffles = 1500;
numSims = 300;
processes = ["indep_ar1", "corr_ar1", "nonlin_lag1", "econometric_proc"];

tic
powers = zeros(length(sampleSizes),2);

pool = parpool(4);
for process = processes
    fprintf('PROCESS: %s\n', process);
    
    parfor i = 1:length(sampleSizes)
        dat = load(sprintf('../data/%s_data.mat', process));

        % Load data generated in Python.
        X_full = dat.X_full;
        Y_full = dat.Y_full;
        
        tic
        n = sampleSizes(i);
        fprintf('SAMPLE SIZE: %d\n', n);
        partialResults = zeros(numSims,1);
        bootstrapedValuesShift=[];
        for s=1:numSims
            X = X_full(1:n, s);
            Y = Y_full(1:n, s);
            sigX = median_heur(X);
            sigY = median_heur(Y);
            [bootShift,bootstrapedValuesShift] = customShiftHSIC(X,Y,alpha,1,min(n, numShuffles),sigX,sigY);   
            partialResults(s) = bootShift.areDependent;
        end           
        toc
        powers(i, :) = [n, mean(partialResults)];
    end
    filename = sprintf("power_curves/shiftHSIC_powers_%s.mat", process);
    save(filename,'powers')
end
toc
delete(pool)