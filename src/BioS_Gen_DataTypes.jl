export PathsDT, TableP, ALLOWED_EXT
export FnaP, FaaP, FastaQP, BamP, SamP, CramP, MmiP, TableP, TxtP, SkaniP, GffP

"""
    PathsDT
    This is an abstract datatype for storing paths toward files. Concrete, composite types are defined further for various types of files. 
    The concrete subtypes have the following fields:
            p::String
            ext::String

    # Concrete subtypes are:

    * FnaP, for nucleic acid fasta files with extensions ".fasta", ".fna", ".fst", ".fas", ".fa", ".mfa"
    * FaaP, for protein fasta files with extensions ".fasta", ".faa", ".fst", ".fas", ".mfa",
    * FastaQP, for sequence read files with extensions ".fastq", ".fq", ".fastq.gz", ".fq.gz", ".fastq.bz2", ".fq.bz2", ".fastq.xz", ".fq.xz",
    * BamP, for Binary Alignment/Map files with extension ".bam",
    * SamP, for Sequence Alignment/Map files with extension ".sam",
    * CramP, for Compressed Read Alignment/Map files with extension ".cram",
    * MmiP, for minimap index files with extension ".mmi", 
    * TableP, for table*like files with extensions ".csv", ".tsv", ".txt",
    * TxtP, for text files with extension ".txt",
    * SkaniP, for Skani related files with extensions ".sketch", ".sketch.gz", ".sketch.bz2", ".sketch.xz"),
    * GffP, for General Feature Format files with extensions ".gff", ".gff3", ".gff.gz", ".gff3.gz", ".gff.bz2", ".gff3.bz2", ".gff.xz", ".gff3.xz", ".gtf", ".gtf.gz", ".gtf.bz2", ".gtf.xz"

    # Constructor example
        FnaP("/path/to/seq.fasta)
        When called like this, the constructor will check in the given path has the proper file extension, and gives and error if not. 

"""
abstract type PathsDT end

const ALLOWED_EXT = Dict(
    "FnaP" => (".fasta", ".fna", ".fst", ".fas", ".fa", ".mfa"),
    "FaaP" => (".fasta", ".faa", ".fst", ".fas", ".mfa"),
    "FastaQP" => (".fastq", ".fq", ".fastq.gz", ".fq.gz", ".fastq.bz2", ".fq.bz2", ".fastq.xz", ".fq.xz"),
    "BamP" => (".bam",),
    "SamP" => (".sam",),
    "CramP" => (".cram",),
    "MmiP" => (".mmi",), ##minimap index
    "TableP" => (".csv", ".tsv", ".txt"),
    "TxtP" => (".txt",),
    "SkaniP" => (".sketch", ".sketch.gz", ".sketch.bz2", ".sketch.xz"),
    "GffP" => (".gff", ".gff3", ".gff.gz", ".gff3.gz", ".gff.bz2", ".gff3.bz2", ".gff.xz", ".gff3.xz", ".gtf", ".gtf.gz", ".gtf.bz2", ".gtf.xz"))


for sym in [:FnaP, :FaaP, :FastaQP, :BamP, :SamP, :CramP, :MmiP, :TableP, :TxtP, :SkaniP, :GffP]
    eval(quote
        struct $sym <: PathsDT
            p::String
            ext::String
        end

        function $sym(p::String)
            ext = getFileExtention(p)
            if ispresent(ext, ALLOWED_EXT[$(string(sym))]) #BioS_Gen.
                return $sym(p, ext)
            else  
                error("The file `$p` with extention `$ext` is not a valid $(ALLOWED_EXT[$(string(sym))]) file type.")
            end
        end
    end)
end

