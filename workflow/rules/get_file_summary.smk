
rule get_file_summary:
    input:
        checked_dir=lambda wc: all_dirs_cfg[wc.lbl]["path"]
    output:
        checked_dir_summary=join(output_dir, "summary", "{lbl}.tsv.gz")
    log:
        join(log_dir, "{lbl}.log")
    benchmark:
        join(benchmark_dir, "{lbl}.tsv")
    params:
        find_ignore_patterns=(
            create_find_ignore_patterns(ignore_patterns)
            if ignore_patterns
            else ""
        )
    threads:
        12
    shell:
        # https://stackoverflow.com/a/25234419
        """
        {{ find {input.checked_dir} ! -readable -prune -o -type f {params.find_ignore_patterns} -size +0 | \
        xargs -P {threads} -I {{}} bash -c '
            file_user=$(stat -c "%U\\t%y" "{{}}" || true);
            file_size=$(du "{{}}" || true);
            if [ -z "${{file_user}}" ] ||  [ -z "${{file_size}}" ]; then
                return 0
            fi
            printf "${{file_user}}\\t${{file_size}}\\n"
        ' \\; | \
        sort -nrk 1,1 | \
        gzip > {output} ;}} 2> {log}
        """


rule get_file_summary_all:
    input:
        expand(rules.get_file_summary.output, lbl=all_dirs_cfg.keys())
