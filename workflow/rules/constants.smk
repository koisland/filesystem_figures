
output_dir=config["output_dir"]
log_dir=config.get("log_dir", "logs")
benchmark_dir=config.get("benchmark_dir", "benchmarks")
ignore_patterns=config.get("ignore_patterns")

all_dirs_cfg = {lbl: cfg for lbl, cfg in config["dirs"].items()}
