import argparse
import datetime
import polars as pl
import plotly.express as px

SUMMARY_COLS_SCHEMA = {
    "user": pl.String,
    "datetime": pl.String,
    "filesize_blocks": pl.UInt64, 
    "abspath": pl.String
}
# Start of lab
DT_START_LAB = datetime.datetime(2024, 1, 3, tzinfo=datetime.timezone.utc)
DT_NOW = datetime.datetime.now(tz=datetime.timezone.utc)
HOVER_DATA = ("user", "abspath", "filesize_gb")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--infile", help="Input summary file.")
    ap.add_argument("-o", "--output_prefix", default="./plot", help="Output prefix.")
    ap.add_argument("-f", "--min_filesize_gb", default=0.0, type=float, help="Minimum file size.")
    ap.add_argument("--static", action="store_true", help="Static output.")
    args = ap.parse_args()
    
    df = (
        pl.scan_csv(
            args.infile,
            separator="\t",
            has_header=False,
            schema=SUMMARY_COLS_SCHEMA
        )
        .with_columns(
            # 2026-01-15 13:46:04.254929404 -0500
            # https://docs.rs/chrono/latest/chrono/format/strftime/index.html
            datetime=pl.col("datetime").str.to_datetime(
                "%Y-%m-%d %H:%M:%S%.f %:z"
            ),
            # https://www.baeldung.com/linux/du-command
            filesize_mb=(pl.col("filesize_blocks") * 1024) / 1_000_000, 
            filesize_gb=(pl.col("filesize_blocks") * 1024) / 1_000_000_000 
        )
        .filter(pl.col("filesize_gb") > args.min_filesize_gb)
        .drop("filesize_blocks")
        .collect()
    )

    df_total_by_user = (
        df
        .group_by(["user"])
        .agg(pl.col("filesize_gb").sum())
        .sort(by="filesize_gb")
    )
    fig_total_by_user = px.bar(
        df_total_by_user,
        x="user",
        y="filesize_gb",
        color="user",
        title="Total filesize by user"
    )
    if args.static:
        fig_total_by_user.write_image(f"{args.output_prefix}_total_by_user.png")
    else:
        fig_total_by_user.write_html(f"{args.output_prefix}_total_by_user.html")

    df_cfilesize = (
        df.sort(by="datetime")
        .with_columns(
            cfilesize_gb=pl.col("filesize_gb").cum_sum()
        )
        .filter(
            pl.col("datetime").ge(pl.lit(DT_START_LAB)) &
            pl.col("datetime").le(pl.lit(DT_NOW))
        )
    )

    fig_cfilesize = px.scatter(
        df_cfilesize,
        x="datetime",
        y="cfilesize_gb",
        color="user",
        hover_data=HOVER_DATA,
        title="Cumulative filesize over time"
    )
    if args.static:
        fig_cfilesize.write_image(f"{args.output_prefix}_cfilesize.png")
    else:
        fig_cfilesize.write_html(f"{args.output_prefix}_cfilesize.html")


    fig_boxplot = px.box(
        df,
        x="user",
        y="filesize_gb",
        color="user",
        points="all",
        hover_data=HOVER_DATA,
        title="Filesize distribution by user"
    )
    if args.static:
        fig_boxplot.write_image(f"{args.output_prefix}_filesize_boxplot.png")
    else:
        fig_boxplot.write_html(f"{args.output_prefix}_filesize_boxplot.html")

if __name__ == "__main__":
    raise SystemExit(main())
