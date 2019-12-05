% Experiment parameters.
sampleSizes = 1200;
nSims = 300;
alpha=0.05;
processes = ["nonlin_dependence_phi_0.20", ...
    "nonlin_dependence_phi_0.30", ...
    "nonlin_dependence_phi_0.40", ...
    "nonlin_dependence_phi_0.50", ...
    "nonlin_dependence_phi_0.60", ...
    "nonlin_dependence_phi_0.70", ...
    "nonlin_dependence_phi_0.80", ...
    "nonlin_dependence_phi_0.95"];
% processes = ["indep_ar1", "corr_ar1", "econometric_proc", "nonlin_lag1", "nonlin_dependence"];

% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')
tic
powers = zeros(length(processes), 2);

%pool = parpool;
%parfor process = processes
for i = 1:length(processes)
    process = processes(i);
    name = split(process, "_");
    rate = str2double(name(4));
    
    dat = load(sprintf('../extinction_data/%s_data.mat', process));
    fprintf("PROCESS: %s\n", process);

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;
    numSims = size(X_full, 2);

    tic
    fprintf("SAMPLE_SIZE: %d\n", sampleSizes);
    partialResults = zeros(numSims, 1);

    for s=1:numSims
        X = X_full(:, s);
        Y = Y_full(:, s);
        partialResults(s) = wildHSIC(X,Y).reject;
    end           
    toc
    powers(i, :) = [rate, mean(partialResults)];
    
    disp(powers)
end
toc
filename = sprintf("power_curves/wildHSIC_powers_nonlinear_dep.mat");
save(filename,'powers')

disp(powers)

%delete(pool)
