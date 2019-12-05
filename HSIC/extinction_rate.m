% Experiment parameters.
sampleSizes = 1200;
numSims = 300;
alpha=0.05;
processes = ["nonlin_dependence_phi_0.20", ...
    "nonlin_dependence_phi_0.30", ...
    "nonlin_dependence_phi_0.40", ...
    "nonlin_dependence_phi_0.50", ...
    "nonlin_dependence_phi_0.60", ...
    "nonlin_dependence_phi_0.70", ...
    "nonlin_dependence_phi_0.80", ...
    "nonlin_dependence_phi_0.95"];


% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')
tic
numShuffles = 1500;
powers = zeros(length(processes), 2);

pool = parpool;
parfor i = 1:length(processes);
    process = processes(i);
    name = split(process, "_");
    rate = str2double(name(4));
    
    dat = load(sprintf('../extinction_data/%s_data.mat', process));
    fprintf("PROCESS: %s\n", process);

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;

    tic
    fprintf("SAMPLE_SIZE: %d\n", sampleSizes);
    partialResults = zeros(numSims, 1);

    bootstrapedValuesShift=[];

    for s=1:numSims
        X = X_full(:, s);
        Y = Y_full(:, s);
        sigX = median_heur(X);
        sigY = median_heur(Y);
        if mod(s-1,10)==0
            [bootShift,bootstrapedValuesShift] = customShiftHSIC(X,Y,alpha,50,min(sampleSizes, numShuffles),sigX,sigY);   
        else
            bootShift = customShiftHSIC(X,Y,alpha,50,min(sampleSizes, numShuffles),sigX,sigY,bootstrapedValuesShift); 
        end       
        partialResults(s) = bootShift.areDependent;
    end           
    toc
    powers(i, :) = [rate, mean(partialResults)];
end           
toc

delete(pool)

filename = sprintf("power_curves/shiftHSIC_powers_extinct_gaus.mat");
save(filename,'powers')

disp(powers)

