"""Boilerplate for pre-processing"""
import click
import pandas as pd


def get_featues(dframe):
    pass


def get_label(dframe):
    pass


def read_raw_data(fname):
    pass


def preprocess_data(dframe):
    pass


def read_processed_data(fname):
    pass


@click.command()
@click.argument(
    "input_file", type=click.Path(exists=True, readable=True, dir_okay=False)
)
@click.argument("output_file", type=click.Path(writable=True, dir_okay=False))
def main(input_file, output_file):
    print("Preprocessing data")
    dframe = read_raw_data(input_file)
    dframe = preprocess_data(dframe)
    dframe.to_pickle(output_file)


if __name__ == "__main__":
    main()
