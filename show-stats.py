from json import loads
from numpy import median
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

np.seterr(invalid="ignore")

fuzzers = [
    "harvey",
    "echidna",
    "foundry",
]


def aggregate_fuzzer_data(fuzzers):
    discovery_time = dict()
    total_bugs = dict()
    total_duration = dict()
    for fuzzer in fuzzers:
        file_name = f"{fuzzer}-results.json"
        with open(file_name) as file:
            data = file.read()
            fuzzer_results = loads(data)
            for res in fuzzer_results:
                program = res["program"]
                tool = res["tool"]
                if fuzzer.startswith(tool):
                    tool = fuzzer
                violations = res["violations"]
                # We aggregate the bug discovery time.
                for bug_id, bug_discovery_time in violations.items():
                    if not (tool in discovery_time):
                        discovery_time[tool] = dict()
                    per_tool_disc_time = discovery_time[tool]
                    glob_bug_id = f"{program}@{bug_id}"
                    if not glob_bug_id in per_tool_disc_time:
                        per_tool_disc_time[glob_bug_id] = []
                    per_bug_disc_time = per_tool_disc_time[glob_bug_id]
                    per_bug_disc_time.append(bug_discovery_time)
                # We aggregate the number of total bugs.
                num_bugs = len(violations)
                if not (tool in total_bugs):
                    total_bugs[tool] = dict()
                bugs_per_tool = total_bugs[tool]
                seed = res["random-seed"]
                if not (seed in bugs_per_tool):
                    bugs_per_tool[seed] = 0
                bugs_per_tool[seed] += num_bugs
                # We aggregate the campaign duration.
                duration = res["duration"]
                if not (tool in total_duration):
                    total_duration[tool] = dict()
                duration_per_tool = total_duration[tool]
                if not (seed in duration_per_tool):
                    duration_per_tool[seed] = 0
                duration_per_tool[seed] += duration
    return discovery_time, total_bugs, total_duration


discovery_time, total_bugs, total_duration = aggregate_fuzzer_data(fuzzers)


def print_text_summary(fuzzers, discovery_time, total_bugs, total_duration):
    for fuzzer in fuzzers:
        print(f"- {fuzzer}")
        unique_bugs = len(discovery_time[fuzzer])
        print(f"  + {unique_bugs} different bugs across all {fuzzer} campaigns")
        found_by_no_other_fuzzer = set(discovery_time[fuzzer].keys())
        for other in fuzzers:
            if other != fuzzer:
                other_bugs = set(discovery_time[other].keys())
                found_by_no_other_fuzzer.difference_update(other_bugs)
        print(
            f"  + {len(found_by_no_other_fuzzer)} bugs not found by any of the other fuzzers across all campaigns"
        )
        bugs_per_seed = list(total_bugs[fuzzer].values())
        num_seeds = len(bugs_per_seed)
        min_bugs = min(bugs_per_seed)
        print(f"  + {min_bugs} bugs (minimum for {num_seeds} campaigns)")
        median_bugs = median(bugs_per_seed)
        print(f"  + {median_bugs} bugs (median for {num_seeds} campaigns)")
        max_bugs = max(bugs_per_seed)
        print(f"  + {max_bugs} bugs (maximum for {num_seeds} campaigns)")
        duration_per_seed = list(total_duration[fuzzer].values())
        median_duration = median(duration_per_seed)
        median_duration_s = median_duration / 1000000000.0
        print(
            f"  + {median_duration_s:.2f}s campaign duration  (median for {num_seeds} campaigns)"
        )


print_text_summary(fuzzers, discovery_time, total_bugs, total_duration)


def create_bar_chart(total_bugs, time_limit):
    sns.set_theme()
    sns.set_style("whitegrid")
    sns.color_palette("deep")
    plt.clf()
    plt.cla()
    df = pd.DataFrame(total_bugs)
    file_name = "final-coverage"
    df.to_csv(f"{file_name}.csv", encoding="utf-8")
    plot = sns.barplot(data=df, estimator=np.median)
    plot.set_xticks(plot.get_xticks())
    plot.set_xticklabels(
        plot.get_xticklabels(), rotation=45, horizontalalignment="right"
    )
    plt.ylabel(f"Number of Violations (after {time_limit} secs)")
    plt.tight_layout()
    plt.savefig(f"{file_name}.pdf")
    plt.savefig(f"{file_name}.png", dpi=300)


time_limit = 28800
create_bar_chart(total_bugs, time_limit)


def num_bugs_at(time, fuzzer, fuzzer_results):
    num_bugs_per_seed = dict()
    for res in fuzzer_results:
        tool = res["tool"]
        if not fuzzer.startswith(tool):
            continue
        seed = res["random-seed"]
        if not (seed in num_bugs_per_seed):
            num_bugs_per_seed[seed] = 0
        num_bugs = 0
        violations = res["violations"]
        for bug_id, bug_discovery_time in violations.items():
            bug_discovery_time_s = bug_discovery_time / 1000000000.0
            if bug_discovery_time_s <= time:
                num_bugs += 1
        num_bugs_per_seed[seed] += num_bugs
    sorted_keys = sorted(num_bugs_per_seed.keys())
    num_bugs_sorted = []
    for k in sorted_keys:
        num_bugs_sorted.append(num_bugs_per_seed[k])
    return num_bugs_sorted


def extract_plot_data(fuzzer, time_limit):
    file_name = f"{fuzzer}-results.json"
    with open(file_name) as file:
        data = file.read()
        fuzzer_results = loads(data)
        plot_data = dict()
        step = 10
        for t in range(0, time_limit + 1, step):
            num_bugs_sorted = num_bugs_at(t, fuzzer, fuzzer_results)
            plot_data[t] = num_bugs_sorted
        return plot_data


def create_line_plot(fuzzers, time_limit, first, second, x_scale="linear"):
    sns.set_theme()
    sns.set_style("whitegrid")
    sns.color_palette("deep")
    plt.clf()
    plt.cla()
    cov_data = []
    for fuzzer in fuzzers:
        fuzzer_data = extract_plot_data(fuzzer, time_limit)
        for t, vs in fuzzer_data.items():
            for v in vs:
                cov_data.append(dict({"fuzzer": fuzzer, "time": t, "violations": v}))
    df = pd.DataFrame(cov_data)
    file_name = "coverage-over-time"
    df.to_csv(f"{file_name}.csv", encoding="utf-8")
    plot = sns.lineplot(
        data=df,
        x="time",
        y="violations",
        hue="fuzzer",
        n_boot=25,
        errorbar=("ci", 95),
        estimator=np.median,
    )
    plot.get_legend().set_title(None)
    if second in fuzzers and first in fuzzers:
        fuzzer_data = extract_plot_data(second, time_limit)
        _, second_y = zip(*sorted(fuzzer_data.items()))
        second_y_mu = [np.median(yi) for yi in second_y]
        second_y_max = max(second_y_mu)
        first_data = extract_plot_data(first, time_limit)
        first_data_sorted = sorted(first_data.items())
        first_x_max = max(
            [xi for xi, yi in first_data_sorted if np.median(yi) <= second_y_max]
        )
        print(
            f"{first} exceeds final number of bugs found by {second} ({second_y_max}) after only {first_x_max} secs!"
        )
        palette = sns.color_palette()
        last_color = palette[len(palette) - 1]
        plt.axhline(y=second_y_max, color=last_color, alpha=0.5, linestyle="-")
        plt.axvline(x=first_x_max, color=last_color, alpha=0.5, linestyle="-")
    plt.xscale(x_scale)
    plt.xlabel("Time (secs)")
    plt.ylabel("Number of Violations")
    plt.tight_layout()
    plt.savefig(f"{file_name}.pdf")
    plt.savefig(f"{file_name}.png", dpi=300)


fuzzer_to_plot = [
    "harvey",
    "foundry",
]
first = "harvey"
second = "foundry"
slack = 200
create_line_plot(fuzzer_to_plot, time_limit + slack, first, second)
