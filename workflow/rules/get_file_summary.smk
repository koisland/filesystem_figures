
rule get_file_summary:
    input:
        checked_dir=lambda wc: all_dirs_cfg[wc.lbl]["path"]
    output:
        checked_dir_summary=join(output_dir, "summary", "{lbl}.tsv.gz"),
        # checked_dir_summary=report(
        #     join(output_dir, "summary", "{lbl}.tsv.gz"),
        #     category="File summary ({lbl})",
        # ),
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
        24
    shell:
        # https://stackoverflow.com/a/25234419
        # 5th column due to date
        # https://www.shellcheck.net/wiki/SC2059
        """
        {{ find {input.checked_dir} ! -readable -prune -o -type f {params.find_ignore_patterns} -size +0 | \
        xargs -P {threads} -I {{}} bash -c '
            file_user=$(stat -c "%U,%y" "{{}}" || true);
            file_size=$(du "{{}}" || true);
            if [ -z "${{file_user}}" ] ||  [ -z "${{file_size}}" ]; then
                return 0
            fi
            printf "%s,%s\\n" "${{file_user}}" "${{file_size}}"
        ' \\; | \
        sed 's/,/\\t/g' | \
        sort -nrk 5,5 | \
        awk -v OFS="\\t" '{{
            is_tempfile=match($8, "tmp|temp") ? "TRUE" : "FALSE";
            is_uncompressed=match($8, "(.bam|.cram|.gz|.bz2|.positions|.index|.bw)$") ? "FALSE" : "TRUE";
            print $0, is_uncompressed, is_tempfile
        }}' | \
        gzip > {output} ;}} 2> {log}
        """


rule get_file_summary_all:
    input:
        expand(rules.get_file_summary.output, lbl=all_dirs_cfg.keys())
