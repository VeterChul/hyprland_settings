path="/home/veter/Pic/dir_oboi"
time_sleep=90

len_path=$(ls $path | wc -l)

if [[ "$len_path" == 1 ]]; then
    paper=$(ls $path)
    path_paper=$(echo "${path}${paper}")
    echo $paper
    swaybg -i "${path_paper}" &
else

    list_paper=("$path"/*)


    while true
    do
        for paper in  "${list_paper[@]}" 
        do  
            swaybg -i "${paper}" &
            sleep $time_sleep
        done
    done
fi