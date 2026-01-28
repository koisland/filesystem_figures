

# https://snakemake.readthedocs.io/en/stable/snakefiles/reporting.html
rule plot_summary:
    input:
        rules.get_file_summary.output.checked_dir_summary
    output:
        join(output_dir, "plots", "{lbl}_total_by_user.html"),
        join(output_dir, "plots", "{lbl}_cfilesize.html"),
        join(output_dir, "plots", "{lbl}_filesize_boxplot.html"),
    params:
        output_prefix=lambda wc, output: join(dirname(output[0]), wc.lbl),
        args=lambda wc: all_dirs_cfg[wc.lbl].get("plot_args", ""),
        script="workflow/scripts/plot.py",
    conda:
        "../envs/tools.yaml"
    shell:
        """
        python {params.script} -i {input} -o {params.output_prefix} {params.args}
        """

rule plot_all:
    input:
        expand(rules.plot_summary.output, lbl=all_dirs_cfg.keys())
