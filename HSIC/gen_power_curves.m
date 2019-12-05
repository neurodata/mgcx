% Experiment parameters.
sampleSizes = 900:100:1000;
alpha=0.05;
processes = ["indep_ar1", "corr_ar1", "econometric_proc", "dynamic_proc"];

% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')
tic
powers = zeros(length(sampleSizes),2);
numShuffles = 1500;

pool = parpool;
for process = processes
    
    fprintf('PROCESS: %s\n', process);
    dat = load(sprintf('data/%s_data.mat', process));

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;
    numSims = size(X_full, 2);

    parfor i = 1:length(sampleSizes)
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
            if mod(i-1,10)==0            
                [bootShift,bootstrapedValuesShift] = customShiftHSIC(X,Y,alpha,50,min(n, numShuffles),sigX,sigY);   
            else
                bootShift = customShiftHSIC(X,Y,alpha,50,min(n, numShuffles),sigX,sigY,bootstrapedValuesShift); 
            end       
            partialResults(s) = bootShift.areDependent;
        end           
        toc
        powers(i, :) = [n, mean(partialResults)];
    end
    filename = sprintf("power_curves/shiftHSIC_powers_%s.mat", process);
    disp(powers)
    save(filename,'powers')
end
toc
delete(pool)