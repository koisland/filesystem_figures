# Filesystem figures

## Getting started
```bash
which snakemake
git clone 
```

## Config
```yaml
output_dir: results
dirs:
  data:
    path: /project/logsdon_shared/data
  long_read_archive:
    path: /project/logsdon_shared/long_read_archive
  project_archive:
    path: /project/logsdon_shared/project_archive
  projects:
    path: /project/logsdon_shared/projects
    # Plot args. See workflow/scripts/plot.py
    plot_args: "--min_filesize_gb 2.0"
  tools:
    path: /project/logsdon_shared/tools
# Ignore specific patterns with find -wholename
ignore_patterns:
  - "*.snakemake/*"
  - "*.git/*"
```

## Usage
```bash
snakemake -p --workflow-profile ~/profiles/lpc -j 6
```
