#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Workflow Params
params.bpm_manifest = '' 
params.csv_manifest = ''
params.cluster_file = ''
params.reference_fa = ''

params.ecr_registry = ''

params.gsa_idats_dir = ''
params.results_dir = ''

log.info """\
             ${version} Worklow one [untitled]
            ==============
            
            Config:
            ==============
            Ref. genome directory [should include *.fa and *.fai files] [--reference_fa <path>]: ${params.reference_fa}
            BPM manifest [--bpm_manifest <path>]: ${params.bpm_manifest}
            CSV manifest [--csv_manifest <path>]: ${params.csv_manifest}
            Cluster file [--cluster_file <path>]: ${params.cluster_file}
            Number of CPUs [--CPUs <int>]: ${params.CPUs} [default: 10]

            Input:
            ==============
            GSA idats [--gsa_idats_dir <path>]: ${params.gsa_idats_dir}

            Output:
            ==============
            results directory [--results_dir <path>]: ${params.results_dir}

""".stripIndent()

process validateParams {
    input:
    path reference_fa
    path reference_fa_index
    path bpm_manifest
    path cluster_file

    script:
    """
    #!/usr/bin/env python3

    import os
    import multiprocessing
    import pandas as pd 

    # --CPUs flag check
    cpus_available = multiprocessing.cpu_count() - 1
    assert ${params.CPUs} <= cpus_available, f"Exceeded number of available cpus --> {${params.CPUs}} / {cpus_available}" 

    # Files flags check
    files = ["$reference_fa", "$reference_fa_index", "$bpm_manifest", "$cluster_file"]
    for file in files:
        assert os.path.exists(file), f"File does not exists {file} {os.getcwd()}"    
    
    """

}

process GtcToVcf {
    container params.ecr_registry + 'illumina-array-analysis-cli'

    memory '16 GB' 

    input:
    path csv_manifest
    path bpm_manifest
    path reference_fa
    path reference_fa_index
    path gtc_dir


    output:
    path 'vcf_files_dir', type: 'dir'

    script:
    """

    array-analysis-cli genotype gtc-to-vcf --csv-manifest $csv_manifest --bpm-manifest $bpm_manifest --genome-fasta-file $reference_fa --gtc-folder $gtc_dir --output-folder vcf_files_dir

    """
}

process callGenotypes {
    container params.ecr_registry + 'illumina-array-analysis-cli'

    memory '24 GB' 

    input: 
    path bpm_manifest
    path cluster_file
    path idats_dir    

    output:
    path 'gtc_files_dir', type: 'dir'

    script:
    """
    array-analysis-cli genotype call --bpm-manifest $bpm_manifest --cluster-file $cluster_file --idat-folder $idats_dir --num-threads ${params.CPUs} --output-folder gtc_files_dir

    """
}

process indexVCF {
    container params.ecr_registry + 'bcftools'

    input:
    path vcf_files_dir

    output:
    path vcf_files_dir, type: 'dir'

    script:
    """
    cd $vcf_files_dir

    find . -type f -name "*.vcf" | xargs -n1 -P${params.CPUs} bgzip
    find . -type f -name "*.vcf.gz" | xargs -n1 tabix -f -p vcf

    #ls *.vcf | xargs -n1 bgzip -@ ${params.CPUs}
    #ls *.vcf.gz | xargs -n1 tabix -f -p vcf
    """
}

process mergeVCF {
    container params.ecr_registry + 'bcftools'
    
    memory '12 GB' 

    input:
    path vcf_files_dir

    output:
    path 'merged.vcf.gz'

    script: 
    """
    
    bcftools merge --threads ${params.CPUs} -o merged.vcf.gz -O z $vcf_files_dir/*/*.vcf.gz
    #bcftools merge --threads ${params.CPUs} -o merged.vcf.gz -O z $vcf_files_dir/*.vcf.gz

    """
}

process filterVCF {
    container params.ecr_registry + 'bcftools'

    input:
    path vcf_file

    output:
    path 'filtered_merged.vcf.gz'

    script: 
    """
    
    bcftools view --threads ${params.CPUs} -m 2 -M 2 $vcf_file -O z -o filtered_merged.vcf.gz

    """
}

process extractGenotypes {
    container params.ecr_registry + 'plink'

    publishDir "$params.results_dir/flow_one", mode: 'copy', overwrite: true, pattern: 'genotypes.vcf.gz'
    publishDir "$params.results_dir/flow_one", mode: 'copy', overwrite: true, pattern: '*.log'

    input:
    path filtered_merged_vcf_file

    output: 
    path 'genotype_table.traw', emit: traw
    path 'genotypes.vcf.gz', emit: vcf
    path '*.log'

    script: 
    """

    plink --vcf $filtered_merged_vcf_file --maf ${params.MAF} --hwe ${params.HWE} --geno ${params.GENO} --autosome --recode A-transpose -out genotype_table
    plink --vcf $filtered_merged_vcf_file --maf ${params.MAF} --hwe ${params.HWE} --geno ${params.GENO} --autosome --recode vcf bgz -out genotypes

    """
}

workflow {
    // Params
    reference_fa = file("$params.reference_fa/*.fa")
    reference_fa_index = file("$params.reference_fa/*.fai")

    bpm_manifest = file(params.bpm_manifest)
    csv_manifest = file(params.csv_manifest)
    cluster_file = file(params.cluster_file)

    // Params validation
    validateParams( reference_fa, reference_fa_index, bpm_manifest, cluster_file )

    // Workflow
    idats_dir = file(params.gsa_idats_dir)

    gtc_dir = callGenotypes( bpm_manifest, cluster_file, idats_dir )
    vcf_dir = GtcToVcf( csv_manifest, bpm_manifest, reference_fa, reference_fa_index, gtc_dir )

    indexed_vcf_dir = indexVCF( vcf_dir )
    merged_vcf = mergeVCF( indexed_vcf_dir )
    filtered_merged_vcf = filterVCF( merged_vcf )

    genotypes = extractGenotypes ( filtered_merged_vcf )
}
