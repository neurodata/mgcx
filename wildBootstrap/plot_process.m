process = 'econometric_proc';
dat = load(sprintf('data/%s_data.mat', process));
X_full = dat.X_full;
Y_full = dat.Y_full;
numSims = size(X_full, 2);

X = X_full(1:n, 2);
Y = Y_full(1:n, 2);

tsX = timeseries(X,1:n);
tsY = timeseries(Y,1:n);
plot(tsY)