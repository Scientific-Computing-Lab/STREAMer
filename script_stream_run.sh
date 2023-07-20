#!/bin/bash

if [ $# -lt 1 ]; then
   echo "You need to provide an input dir, that contains formatted sub-directories to process"
fi

input_dir=$1

if [ -d "$input_dir" ]; then
   echo "Input directory: $input_dir"
   for dir in "$input_dir"/*/; do
      
        dir=$(basename "${dir}")
	echo "-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-"
	echo "Working on $dir"

	OLDIFS=$IFS
	IFS="_"
	parts=($dir)
	IFS=$OLDIFS

	hyper_threading=${parts[0]}
	cores=${parts[1]}
	memory=${parts[2]}
	thread_affinity=${parts[3]}
	first_touch=${parts[4]}
        dax_path_tmp=${parts[5]}
	dax_path=$(echo "$dax_path_tmp" | tr '@' '/') #change '@' to '/'
        arrays_size_tmp=${parts[6]}
	arrays_size=${arrays_size_tmp#Arrays}
        number_of_cores_per_socket_tmp=${parts[7]}
	number_of_cores_per_socket=${number_of_cores_per_socket_tmp#Cores}

	echo "--------- Requested parameters: ---------"

	echo "Hyper Threading: $hyper_threading"
	echo "Cores: $cores"
	echo "Memory: $memory"
	echo "Thread Affinity: $thread_affinity"
	echo "First Touch: $first_touch"
	if [[ $dax_path != "" ]]; then
	echo "Dax Path: $dax_path"
        echo "Arrays Size: $arrays_size"
        echo "Number of Cores per Socket: $number_of_cores_per_socket"
	fi

	echo "--------- Status of parameters enabled: ---------"



	#hyperthreading 
	if [[ $cores != "Socket0Socket1"  ]]; then
	  if [[ $hyper_threading == "noHT" ]]; then
 	    threads=($(seq 1 $((number_of_cores_per_socket))))
	  else
	     threads=($(seq 1 $((2*number_of_cores_per_socket))))
	  fi
	else
 	  if [[ $hyper_threading == "noHT" ]]; then
 	    threads=($(seq 1 $((2*number_of_cores_per_socket))))
	  else
 	    threads=($(seq 1 $((4*number_of_cores_per_socket))))
	  fi
	fi

	echo "Executing Threads from ${threads[0]} to ${threads[${#threads[@]}-1]}"



	#first touch
	if [[ $first_touch == "FT" ]]; then
	  firsttouch_compilation_flag="-DFIRSTTOUCH"
	  echo "First Touch enabled"
	else
	  firsttouch_compilation_flag=""
	  echo "First Touch enabled"
	fi


	#thread affinity
	if [[ $thread_affinity == "Close" ]]; then
	  export OMP_PROC_BIND="close"
	  echo "Thread Affinity is set to close"
	else
	  export OMP_PROC_BIND="spread"
	  echo "Thread Affinity is set to spread"
	fi
   

	#compilation
	if [[ $memory == *DAX* ]]; then
	  echo "compiling stream_pmemobj.c"
          gcc -fopenmp -lpmemobj -lpmem -O -DSTREAM_ARRAY_SIZE=$arrays_size -D_OPENMP stream_pmemobj.c -o stream_pmemobj
	else
	  echo "compiling stream.c"
	  gcc -fopenmp -O -DSTREAM_ARRAY_SIZE=$arrays_size -D_OPENMP $firsttouch_compilation_flag stream.c -o stream
	fi


	#execution
	tmp_csv="$input_dir/$dir/output_data.csv"
	echo "Number of Threads,Copy Rate (MB/s),Scale Rate (MB/s),Add Rate (MB/s),Triad Rate (MB/s)" > "$tmp_csv"
	for thread in "${threads[@]}"; do

                export OMP_NUM_THREADS=$thread
                output_file=$"$input_dir/$dir/output.$thread.txt"

                #NEED HERE TO RUN ACCORDING TO PARAMETERS: DAX PATH, NUMACTL
                
                if [[ $memory == *DAX* ]]; then  #no memory binding
                
                    if [[ $cores == "Socket0Socket1" ]]; then #no cpu binding
                        cmd="numactl ./stream_pmemobj $dax_path > $output_file"
                    elif [[ $cores == "Socket0" ]]; then  #--cpunodebind=0
                        cmd="numactl --cpunodebind=0 ./stream_pmemobj $dax_path > $output_file"
                    elif [[ $cores == "Socket1" ]]; then  #--cpunodebind=1
                        cmd="numactl --cpunodebind=1 ./stream_pmemobj $dax_path > $output_file"
                    fi

                elif [[ $memory == "Socket0"* ]]; then #--membind=0

                    if [[ $cores == "Socket0Socket1" ]]; then #no cpu binding
                        cmd="numactl --membind=0 ./stream > $output_file"
                    elif [[ $cores == "Socket0" ]]; then  #--cpunodebind=0
                        cmd="numactl --membind=0 --cpunodebind=0 ./stream > $output_file"
                    elif [[ $cores == "Socket1" ]]; then  #--cpunodebind=1
                        cmd="numactl --membind=0 --cpunodebind=1 ./stream > $output_file"
                    fi

                elif [[ $memory == "Socket1"* ]]; then #--membind=1
 
                    if [[ $cores == "Socket0Socket1" ]]; then #no cpu binding
                        cmd="numactl --membind=1 ./stream > $output_file"
                    elif [[ $cores == "Socket0" ]]; then  #--cpunodebind=0
                        cmd="numactl --membind=1 --cpunodebind=0 ./stream > $output_file"
                    elif [[ $cores == "Socket1" ]]; then  #--cpunodebind=1
                        cmd="numactl --membind=1 --cpunodebind=1 ./stream > $output_file"
                    fi

                elif [[ $memory == "CXL"* ]]; then #--membind=2
                    if [[ $cores == "Socket0Socket1" ]]; then #no cpu binding
                        cmd="numactl --membind=2 ./stream > $output_file"
                    elif [[ $cores == "Socket0" ]]; then  #--cpunodebind=0
                        cmd="numactl --membind=2 --cpunodebind=0 ./stream > $output_file"
                    elif [[ $cores == "Socket1" ]]; then  #--cpunodebind=1
                        cmd="numactl --membind=2 --cpunodebind=1 ./stream > $output_file"
                    fi
                fi
           
                echo "Executing: $cmd"
                eval "$cmd"
                copy_rate=$(grep "Copy:" "$output_file" | awk '{print $2}')
                scale_rate=$(grep "Scale:" "$output_file" | awk '{print $2}')
                add_rate=$(grep "Add:" "$output_file" | awk '{print $2}')
                triad_rate=$(grep "Triad:" "$output_file" | awk '{print $2}')

                echo "$thread,$copy_rate,$scale_rate,$add_rate,$triad_rate" >> "$tmp_csv"
                echo DONE $thread threads
        done
        column -t -s "," "$tmp_csv"
        echo "Output data saved in $tmp_csv"
	python3 plot_results.py "$input_dir/$dir"
    done
else
echo "Input Directory not found: $input_dir"
fi
