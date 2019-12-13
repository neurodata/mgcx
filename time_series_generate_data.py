import pickle
from pathlib import Path

import numpy as np
from scipy.io import savemat, loadmat

from mgcpy.benchmarks.ts_benchmarks import (
    IndependentAR1,
    CorrelatedAR1,
    Nonlinear,
    EconometricProcess,
    ExtinctGaussian,
)


def _simulate_data(process, n_max, num_sims, output_dir="./data"):
    # Store simulate processes.
    X_full = np.zeros((n_max, num_sims))
    Y_full = np.zeros((n_max, num_sims))
    for s in range(num_sims):
        X_full[:, s], Y_full[:, s] = process.simulate(n_max)

    # Save simulated output.
    output = {"X": X_full, "Y": Y_full}
    p = Path(output_dir)
    if not p.is_dir():
        p.mkdir(parents=True)

    filename = p / f"{process.filename}_data.pkl"
    file = open(filename, "wb")
    pickle.dump(output, file)
    file.close()

    # Save to MATLAB format as well.
    savemat(p / f"{process.filename}_data.mat", {"X_full": X_full, "Y_full": Y_full})


def generate_extinct_gaussians(
    phis, n_max, num_sims, output_dir="./data/extinct_rates/"
):
    """
    phis = list
    """
    for phi in phis:
        process = ExtinctGaussian(extinction_rate=phi)

        X_full = np.zeros((n_max, num_sims))
        Y_full = np.zeros((n_max, num_sims))
        for s in range(num_sims):
            X_full[:, s], Y_full[:, s] = process.simulate(n_max)

        # Save to MATLAB format as well.
        p = Path(output_dir)
        if not p.is_dir():
            p.mkdir(parents=True)

        savemat(
            p / f'{process.filename}_phi_{"{:.3f}".format(phi)}_data.mat',
            {"X_full": X_full, "Y_full": Y_full},
        )


def generate_varying_indep_ars(phis, n_max, num_sims, output_dir="./data/ars/"):
    """
    phis = list
    """
    for phi in phis:
        sigma = np.sqrt(1 - phi ** 2)
        process = IndependentAR1()

        X_full = np.zeros((n_max, num_sims))
        Y_full = np.zeros((n_max, num_sims))
        for s in range(num_sims):
            X_full[:, s], Y_full[:, s] = process.simulate(
                n=n_max, phi=phi, sigma2=sigma
            )

        # Save to MATLAB format as well.
        p = Path(output_dir)
        if not p.is_dir():
            p.mkdir(parents=True)

        savemat(
            p / f'{process.filename}_phi_{"{:.3f}".format(phi)}_data.mat',
            {"X_full": X_full, "Y_full": Y_full},
        )


if __name__ == "__main__":
    processes = [
        IndependentAR1(),
        CorrelatedAR1(),
        Nonlinear(),
        EconometricProcess(shift=0.5, scale=0.1),
        ExtinctGaussian(),
    ]

    np.random.seed(1)
    for process in processes:
        _simulate_data(process, n_max=1000, num_sims=1000)

    phis = np.arange(0.2, 1, 0.025)
    n_max = 1200
    n_sims = 1000

    np.random.seed(1)
    generate_extinct_gaussians(phis, n_max, n_sims)

    phis = np.arange(0.1, 1, 0.05)
    n_max = 1200
    n_sims = 1000

    np.random.seed(1)
    generate_varying_indep_ars(phis, n_max, n_sims)
