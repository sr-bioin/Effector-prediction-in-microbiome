## Effector predicton

Sec-dependent effectors, protein sequences were screened for Sec signal peptides. Proteins possessing signal pep-tides for the Sec-dependent pathway were identified using following softwares. 
SignalP : SignalP predicts the presence and location of signal peptide cleavage sites in amino acid sequences from different organisms: Gram-positive prokaryotes, Gram-negative prokaryotes, and eukaryotes. The method incorporates a prediction of cleavage sites and a signal peptide/non-signal peptide prediction based on a combination of several artificial neural networks and hidden Markov models.
#### Command used for SignalP3: https://services.healthtech.dtu.dk/services/SignalP-3.0/ 
    signalp -t gram- -f short -u 0.44 /Whole_genome_analysis/Clavibacter/$sample.fasta > / Whole_genome_analysis/Clavibacter/INTERPROSCAN/Signalp4.1/$sample_signP4_OPR.out

#### Command used for SignalP4: https://services.healthtech.dtu.dk/services/SignalP-4.1/
    interproscan.sh -f TSV -appl SignalP-GRAM_NEGATIVE -i /Whole_genome_analysis/Clavibacter/Proteins/$sample.fasta -b /Whole_genome_analysis/Clavibacter/INTERPROSCAN/Signalp4.1/$sample.iprscan.signalp_4

Phobious:- Phobius is a program for prediction of transmembrane topology and signal peptides from the amino acid sequence of a protein. https://phobius.sbc.su.se/
#### Command used for Phobius:
    interproscan.sh -f TSV -appl Phobius -i /Whole_genome_analysis/Clavibacter/Proteins/$sample.fasta -b /Whole_genome_analysis/Clavibacter/INTERPROSCAN/Phobius/$sample.phobius

Predicted lipoproteins and transmembrane proteins were filtered from the Sec secretomes.

Lipop: It produces predictions of lipoproteins and discriminates between lipoprotein signal peptides, other signal peptides and n-terminal membrane helices in Gram-negative bacteria. https://services.healthtech.dtu.dk/services/LipoP-1.0/
#### Command used for lipoP: 
    perl LipoP -short -html /Whole_genome_analysis/Proteins/$sample.faa > $sample_.lipoP

DeepTMHMM is a deep learning protein language model-based algorithm that can detect and predict the topology of both alpha helical and beta barrels proteins over all domains of life. https://services.healthtech.dtu.dk/services/DeepTMHMM-1.0/ 
#### Command used for deepTMHMM:
     interproscan.sh -f TSV -appl TMHMM -i /Whole_genome_analysis/Clavibacter/Proteins/compliantFasta/$sample.fasta -b /Whole_genome_analysis/Clavibacter/INTERPROSCAN/TMHMM/$sample.TMHMM


## Phylogenetic analyses
Orthologous genes of Las isolates were predicted using the OrthoMCL v. 2.0 pipeline (Li et al., 2003). 

#### orthomcl clustering
    blastall -d goodNucleotides.fasta -p blastn -i goodNucleotides.fasta -m 8 -e 1e-5 -o goodNucleotides_blast_result.out
    orthomclBlastParser /Clavibacter/OrthoMCL/Genes/goodprotein_blast_result.out /Clavibacter/OrthoMCL/Genes/compliantFasta > similarSequences.txt
    orthomclInstallSchema orthomcl.config mysql.log
    orthomclLoadBlast orthomcl.config similarSequences.txt
    orthomclPairs orthomcl.config orthomcl_pairs.log cleanup=no
    orthomclDumpPairsFiles orthomcl.config > dump.log
    mcl mclInput --abc -t 10 -I 1.5 -o mcl_Output
    orthomclMclToGroups CLas 00001 < mcl_Output > groups.txt

Multiple alignments of gene sequences were done with PRANK v. 170,427 (Löytynoja, 2014). 

#### Command used for PRANK: 
      prank -d=CLas.fasta -o=CLas_prank.fasta -DNA -F

#### All the alignments were concatenated by FASconCAT v. 1.1, yielding a gene supermatrix (Kuck and Meusemann, 2010). 
    perl FASconCATv.1.1.pl

A maximum-likelihood approach was used to reconstruct the phylogenetic tree using RAxML v. 8.2 software (Stamatakis, 2006). 
#### Command used for RAxML:
      raxmlHPC-PTHREADS-SSE3 -k -f a -m GTRGAMMA -d -p 12345 -x 12345 -s FcC_smatrix.fasta -n FcC_GAMMA_raxML_N.out -N 1000 -T 12
