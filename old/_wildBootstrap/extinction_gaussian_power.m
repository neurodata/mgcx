% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')

% Experiment parameters.
sampleSizes = 1200;
nSims = 300;
alpha=0.05;
phis = 0.2:0.025:.975;
nCores = 4;

dataPath = "../data/extinct_rates/extinct_gaussian_phi_%s_data.mat";

%%%%%%%%%%%%%%%%%%%%%%%
% Run for test type 1 %
%%%%%%%%%%%%%%%%%%%%%%%
tic
powers = zeros(length(phis), 2);

pool = parpool(nCores);
parfor i = 1:length(phis)
%for i = 1:length(phis)
    phi = phis(i);
    rate = num2str(phis(i), "%.3f");
    process = sprintf(dataPath, rate);
    %name = split(process, "_");
    %rate = str2double(name(5));
    
    dat = load(process);
    fprintf("PROCESS: %s\n", phis(i));

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;
    numSims = size(X_full, 2);

    tic
    partialResults = zeros(numSims, 1);

    for s=1:numSims
        X = X_full(:, s);
        Y = Y_full(:, s);
        partialResults(s) = wildHSIC(X,Y,'Test',1,'NumBootstrap',100).reject;
    end           
    toc
    powers(i, :) = [phis(i), mean(partialResults)];
end
toc

delete(pool)

filename = sprintf("power_curves/wildHSIC_powers_extinct_gaussian.mat");
save(filename,'powers')

disp(powers)


%%%%%%%%%%%%%%%%%%%%%%%
% Run for test type 2 %
%%%%%%%%%%%%%%%%%%%%%%%
tic
powers = zeros(length(phis), 2);

pool = parpool(nCores);
parfor i = 1:length(phis)
%for i = 1:length(phis)
    phi = phis(i);
    rate = num2str(phis(i), "%.3f");
    process = sprintf(dataPath, rate);
    %name = split(process, "_");
    %rate = str2double(name(5));
    
    dat = load(process);
    fprintf("PROCESS: %s\n", phis(i));

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;
    numSims = size(X_full, 2);

    tic
    partialResults = zeros(numSims, 1);

    for s=1:numSims
        X = X_full(:, s);
        Y = Y_full(:, s);
        partialResults(s) = wildHSIC(X,Y,'Test',2,'NumBootstrap',100).reject;
    end           
    toc
    powers(i, :) = [phis(i), mean(partialResults)];
end
toc

delete(pool)

filename = sprintf("power_curves/wildHSIC2_powers_extinct_gaussian.mat");
save(filename,'powers')

disp(powers)
