cat *.bedfa.2 | awk '$4 == "HIGH" {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |
perl -pi -e 's/$/\tHOTSPOT\t0\t+/' > HOTSPOT.temp && name.pl HOTSPOT.temp HOTSPOT.TEMP && /bin/rm HOTSPOT.temp

cat *.bedfa.2 | awk '$4 == "MEDIUM" {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tMEDIUM\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP > MEDIUM.temp && name.pl MEDIUM.temp MEDIUM.TEMP && /bin/rm MEDIUM.temp

cat *.bedfa.2 | awk '$4 ~ /SPARSE_HIGH/ {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tHOTSPOT_EXT\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP | bedtools subtract -a - -b MEDIUM.TEMP > HOTSPOT_EXT.temp && 
name.pl HOTSPOT_EXT.temp HOTSPOT_EXT.TEMP && /bin/rm HOTSPOT_EXT.temp


cat *.bedfa.2 | awk '$4 == "SPARSE" {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tSPARSE\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP |bedtools subtract -a - -b MEDIUM.TEMP |
bedtools subtract -a - -b HOTSPOT_EXT.TEMP > SPARSE.temp &&
name.pl SPARSE.temp SPARSE.TEMP && /bin/rm SPARSE.temp

cat *.TEMP |sort -k1 -k2,2n > Peaks.final
/bin/rm *.TEMP
