from argparse import ArgumentParser
from pathlib import Path

import numpy as np
import pandas as pd
from joblib import Parallel, delayed
from scipy.io import loadmat, savemat

from mgcpy.independence_tests.dcorrx import DCorrX
from mgcpy.independence_tests.mgcx import MGCX
from mgcpy.independence_tests.xcorr import BoxPierceX, LjungBoxX


def _compute_power(test, X_full, Y_full, num_sims, alpha, n, replication_factor=100):
    """
    Helper method estimate power of a test on a given simulation.

    :param test: Test to profile, either DCorrX or MGCX.
    :type test: TimeSeriesIndependenceTest

    :param X_full: An ``[n*num_sims]`` data matrix where ``n`` is the highest sample size.
    :type X_full: 2D ``numpy.array``

    :param Y_full: An ``[n*num_sims]`` data matrix where ``n`` is the highest sample size.
    :type Y_full: 2D ``numpy.array``

    :param num_sims: number of simulation at each sample size.
    :type num_sims: integer

    :param alpha: significance level.
    :type alpha: float

    :param n: sample size.
    :type n: integer

    :return: returns the estimated power.
    :rtype: float
    """
    num_rejects = 0.0

    def worker(s):
        X = X_full[range(n), s]
        Y = Y_full[range(n), s]
        if test["name"] in ["DCorr-X", "MGC-X"]:
            p_value, _ = test["object"].p_value(
                X, Y, replication_factor=replication_factor, is_fast=test["is_fast"]
            )
        else:
            p_value = test["object"].p_value(
                X, Y, replication_factor=replication_factor
            )

        if p_value <= alpha:
            return 1.0
        return 0.0

    rejects = Parallel(n_jobs=-2, verbose=1)(
        delayed(worker)(s) for s in range(num_sims)
    )
    power = np.mean(rejects)
    std = np.std(rejects)

    return power, std


def main(task_index):
    n = 1200
    alpha = 0.05
    num_sims = 300

    tests = [
        {
            "name": "DCorr-X",
            "filename": "dcorrx",
            "is_fast": False,
            "subsample_size": -1,
            "object": DCorrX(max_lag=1),
        },
        {
            "name": "LjungX",
            "filename": "ljungx",
            "object": LjungBoxX(max_lag=1),
            "color": "k",
        },
        {
            "name": "BoxPierceX",
            "filename": "boxpiercex",
            "object": LjungBoxX(max_lag=1),
            "color": "k",
        },
        {
            "name": "MGC-X",
            "filename": "mgcx",
            "is_fast": False,
            "object": MGCX(max_lag=1),
        },
    ]

    p = Path("../../data/ars")
    processes = sorted(p.glob("*mat"))
    process = processes[int(task_index)]
    phi = process.name.split("_")[-2]
    df = pd.DataFrame([phi], columns=["ar_coeff"])

    for test in tests:
        print(f"Running test: {test['name']}")
        powers = np.zeros(1)
        stds = np.zeros(1)

        print(f"AR Coefficient: {phi}")
        data = loadmat(process)
        X_full = data["X_full"]
        Y_full = data["Y_full"]

        powers[0], stds[0] = _compute_power(test, X_full, Y_full, num_sims, alpha, n)

        test_name = test["name"]
        tmp_df = pd.DataFrame(
            np.array([powers, stds]).T,
            columns=[f"{test_name}_powers", f"{test_name}_stds"],
        )

        df = pd.concat([df, tmp_df], axis=1)

    df.to_csv(f"./indep_ars_{phi}.csv", index=False)


if __name__ == "__main__":
    parser = ArgumentParser(
        description="This is a script for running mgcx experiments."
    )
    parser.add_argument("task_index", help="SLURM task index")

    result = parser.parse_args()
    task_index = result.task_index
    main(task_index)
