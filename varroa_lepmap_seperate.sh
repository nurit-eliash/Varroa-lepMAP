##############################
##      * ParentCall2 *     ##
##############################
# The module ParentCall2 is used to call parental genotypes and markers.

java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 vcfFile=Q40BIALLDP16HDP40mis.5Chr7.Rm34Sites.recode.vcf data=pedigree.txt removeNonInformative=1 > data.call

##############################
##      ֿ * Filtering2 *     ##
##############################
java -cp /home/n/nurit-eliash/lepmap/bin Filtering2 data=data.call dataTolerance=0.01 removeNonInformative=1 outputHWE=1 MAFLimit=0.2  >data_f_maf0.2.call

##############################
## * SeparateChromosomes2 * ##
##############################
# The SeparateChromosomes2 module assigns markers into linkage groups (LGs) 
java -cp /home/n/nurit-eliash/lepmap/bin SeparateChromosomes2 data=data_f_maf0.2.call distortionLod=1 sizeLimit=3 lodLimit=4 > map3_4.txt

# options for SeparateChromosomes2:

# '(fe)maleTheta=0'    Fixed recombination fraction separately for both sex [theta]
# this assume no recombintaion in males, the default recombintaion rate for all individuals is ‘theta=0.03’


##############################
##   * JoinSingles2All *    ##
##############################
# join markers that were left over after seperating them into exsisting linkage groups
# define lodLimit belowe the one in SeparateChromosomes2
java -cp /home/n/nurit-eliash/lepmap/bin JoinSingles2All map=map3_4.txt data=data_f_maf0.2.call iterate=1 lodLimit=2 > map3_4_js.txt


##############################
##     * OrderMarkers2 *    ##
##############################
# orders the markers within each LG by maximizing the likelihood of the data given the order. 
# assume recombintaions in males anf females
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_4_js.txt data=data_f_maf0.2.call useKosambi=1 numMergeIterations=100 sexAveraged=0 outputPhasedData=2 grandparentPhase=1 recombination1=0.01 recombination2=0.01 > order.txt

##############################
## * markers to position *  ##
##############################
# Converting marker numbers (1..N) back to genomic coordinates (order.txt is the output from OrderMarkers2 using data data.call coming from ParentCall2):

cut -f 1,2 data.call|awk '(NR>=7)' > snps.txt

#note that first line of snps.txt contains "CHR POS"
awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' snps.txt order.txt >order.mapped
#because of first line of snps.txt, we use NR-1 instead of NR