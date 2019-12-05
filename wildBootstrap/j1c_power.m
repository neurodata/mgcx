% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')

% Experiments
sampleSizes = 25;
alpha=0.05;
% processes = ["indep_ar1", "corr_ar1", "econometric_proc", "nonlin_lag1", "nonlin_dependence"];
processes = ("indep_ar1");
nSims = 200;


dat = load(sprintf('data/%s_data.mat', processes(1)));
fprintf("PROCESS: %s\n", processes(1));

% Load data generated in Python.
X_full = dat.X_full;
Y_full = dat.Y_full;
    

%res = zeros(length(sampleSizes), 1);
partialResults = zeros(nSims, 1);
tic
for j = 1:nSims
    X = X_full(1:sampleSizes, j);
    Y = Y_full(1:sampleSizes, j);

    test = wildHSIC(X, Y, 'alpha', alpha);
    partialResults(j, 1) = test.reject;
end
toc

res = mean(partialResults);


disp(res);