#!/bin/sh

tag="[isabella-mon]"
 
du -h /scratch/*  > /scratch/for_del 

#provjerava datoteke oblika job-id.brojevi.slova.q 
for f in $(ls /scratch/ | egrep [0-9]+.[0-9]+.[a-z]+.q | sed s/[.].*//g | sort -n | uniq); do 
        if [[ $(qstat -u "*" | grep $f | wc -l) != 0 || $(lsof | grep ${f} | wc -l) != 0 ]]; then 
                sed -i '/'${f}'.*/d' /scratch/for_del 
        fi 
done 

#provjerava datoteke koje nisu gore navedenog oblika
for f in $(ls /scratch/ | egrep -v [0-9]+.[0-9]+.[a-z]+.q | egrep -v lost+found); do  
        if [[ $(lsof | grep ${f} | wc -l) != 0 ]]; then  
                sed -i '/'${f}'/d' /scratch/for_del  
        fi  
done 

#daje sansu mladjima od 30 dana
touch -d '1 month ago' /scratch/1mon
for f in $(cat /scratch/for_del | awk '{print substr($2,10)}'); do
	if [ $f -nt /scratch/1mon ]; then
		echo $(cat /scratch/for_del | grep $f) >> /scratch/rescue_me
		sed -i '/'${f}'/d' /scratch/for_del
	fi
done
rm -f /scratch/1mon

#salje mail/brise
if [[ -s /scratch/for_del ]] ; then 
        cat /scratch/for_del | mail -s "$tag Files for deletion on $(hostname)" "isabella-dezurni@srce.hr"
	if [[ -s /scratch/rescue_me ]] ; then
		cat /scratch/rescue_me | mail -s "$tag Files for rescuing on $(hostname)" "isabella-dezurni@srce.hr"  
	fi
        #cat /scratch/for_del | awk '{print $2}' | xargs rm -rf  
        rm -f /scratch/for_del /scratch/rescue_me 
else 
        rm -f /scratch/for_del /scratch/rescue_me
fi