
import os
import warnings
warnings.simplefilter('ignore')

import pandas as pd
import subprocess

import dms_tools2
import dms_tools2.plot
import dms_tools2.dssp
import dms_tools2.sra

print("Using dms_tools2 version {}".format(dms_tools2.__version__))


def main():

    # -----------------------------
    # Setup directories and options
    # -----------------------------
    resultsdir = './results/'
    if not os.path.isdir(resultsdir):
        os.mkdir(resultsdir)

    ncpus = -1
    use_existing = 'yes'

    # -----------------------------
    # Sample sheet
    # -----------------------------
    samples = pd.DataFrame.from_records(
        [
            ('MutDNA', 'SRR3113656', 'MutDNA_R1.fastq.gz', 'MutDNA_R2.fastq.gz'),
            ('Mutplasmid', 'SRR3113657', 'Mutplasmid_R1.fastq.gz', 'Mutplasmid_R2.fastq.gz'),
            ('Wtplasmid', 'SRR3113658', 'Wtplasmid_R1.fastq.gz', 'Wtplasmid_R2.fastq.gz'),
            ('DMS library', 'SRR3113659', 'DMS library_R1.fastq.gz', 'DMS library_R2.fastq.gz'),
            ('Wtvirus', 'SRR3113660', 'Wtvirus_R1.fastq.gz', 'Wtvirus_R2.fastq.gz'),
        ],
        columns=['name', 'run', 'R1', 'R2']
    )

    fastqdir = os.path.join(resultsdir, 'FASTQ_files/')
    print("\nSample sheet loaded:")
    print(samples)

    # -----------------------------
    # Reference sequence and alignspecs
    # -----------------------------
    refseq = './data/BJ16.fasta'

    alignspecs = ' '.join([
        '1,281,33,35',
        '282,563,37,30',
        '564,839,39,33',
        '840,1120,33,34',
        '1121,1405,29,34',
        '1406,1683,27,34'
    ])

    # -----------------------------
    # Create codon counts directory
    # -----------------------------
    countsdir = os.path.join(resultsdir, 'codoncounts')
    if not os.path.isdir(countsdir):
        os.mkdir(countsdir)

    # -----------------------------
    # Write batch.csv
    # -----------------------------
    countsbatchfile = os.path.join(countsdir, 'batch.csv')
    print("\nWriting batch file to:", countsbatchfile)

    samples[['name', 'R1']].to_csv(countsbatchfile, index=False)
    print(samples[['name', 'R1']])

    # -----------------------------
    # Run dms2_batch_bcsubamplicons
    # -----------------------------
    print("\nRunning dms2_batch_bcsubamp...")

    cmd = [
        "dms2_batch_bcsubamp",
        "--batchfile", countsbatchfile,
        "--refseq", refseq,
        "--alignspecs", alignspecs,
        "--outdir", countsdir,
        "--summaryprefix", "summary",
        "--R1trim", "200",
        "--R2trim", "170",
        "--fastqdir", fastqdir,
        "--ncpus", str(ncpus),
        "--use_existing", use_existing
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    print("\n===== dms2_batch_bcsubamp OUTPUT =====")
    print(result.stdout)
    print("===== END OUTPUT =====")

    if result.stderr:
        print("\nWarnings / Errors:")
        print(result.stderr)

    print("\nCompleted dms2_batch_bcsubamp.")


if __name__ == "__main__":
    main()
