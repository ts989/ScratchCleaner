#! bin/sh 
 
du -h /scratch/*  > /scratch/for_del 

#Provjerava datoteke oblika job-ID.brojevi.slova.q 
for f in $(ls /scratch/ | egrep [0-9]+.[0-9]+.[a-z]+.q | sed s/[.].*//g | sort -n | uniq); do 
        if [[ $(qstat -u "*" | grep $f | wc -l) != 0 || $(lsof | grep ${f} | wc -l) != 0 ]]; then 
                sed -i '/'${f}'.*/d' /scratch/for_del 
        fi 
done 

#Provjerava datoteke koje nisu gore navedenog oblika
for f in $(ls /scratch/ | egrep -v [0-9]+.[0-9]+.[a-z]+.q ); do  
        if [[ $(lsof | grep ${f} | wc -l) != 0 ]]; then  
                sed -i '/'${f}'/d' /scratch/for_del  
        fi  
done 

#Salje mail/brise
if [[ -s /scratch/for_del ]] ; then 
        cat /scratch/for_del | mail -s "Files for deletion on '$(hostname)'" "neki_mail@srce.hr"  
        #cat /scratch/for_del | awk '{print $2}' | xargs rm -rf  
        rm -f /scratch/for_del  
else 
        rm -f /scratch/for_del 
fi
