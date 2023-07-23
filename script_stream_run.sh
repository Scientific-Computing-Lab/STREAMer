#!/bin/bash

if [ $# -lt 1 ]; then
   echo "You need to provide an input dir that contains formatted sub-directories to process"
fi

input_dir=$1
override=false #on default, script jumps over subdirectories that already contain files

if [ $# -gt 1 ]; then
   if [[ $2 == 'override' ]]; then
     override=true
   fi
fi

if [ -d "$input_dir" ]; then
   echo "Input directory: $input_dir"
   for dir in "$input_dir"/*/; do
        if [ -e "$dir/graph_results.svg" ] && [ "$override" = false ]; then
          echo "Skipping $(basename "${dir}"). To enable overriding pass another agrument to the script: override"
           continue
        fi
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
        log_file="$input_dir/$dir/log_config.txt"
        
	# Save lscpu information to the log file
	echo "lscpu Information:" >> "$log_file"
	echo "==================" >> "$log_file"
	lscpu >> "$log_file"
	echo "" >> "$log_file"  # Add an empty line for better readability
	
	# Save dmesg output to the log file
	echo "dmesg Output:" >> "$log_file"
	echo "=============" >> "$log_file"
	dmesg >> "$log_file"
	echo "" >> "$log_file"  # Add an empty line for better readability
	
	# Save numactl output to the log file
	echo "numactl Output:" >> "$log_file"
	echo "===============" >> "$log_file"
	numactl -H >> "$log_file"
	echo "" >> "$log_file"  # Add an empty line for better readability
	
	# Check if dmidecode is installed on the server
	if command -v dmidecode &> /dev/null; then
	  # Save dmidecode output to the log file
	  echo "dmidecode Output:" >> "$log_file"
	  echo "=================" >> "$log_file"
	  dmidecode >> "$log_file"
	  echo "" >> "$log_file"  # Add an empty line for better readability
	else
	  # Inform that dmidecode is not installed
	  echo "dmidecode is not installed on the server." >> "$log_file"
	  echo "" >> "$log_file"  # Add an empty line for better readability
	fi
	
	# Check if ipmctl is installed on the server
	if command -v ipmctl &> /dev/null; then
	  # Save ipmctl output to the log file
	  echo "ipmctl Output:" >> "$log_file"
	  echo "==============" >> "$log_file"
	  ipmctl show -memoryresources >> "$log_file"
	  echo "" >> "$log_file"  # Add an empty line for better readability
	fi

        # Check if ndctl is installed on the server
	if command -v ndctl &> /dev/null; then
	  # Save ipmctl output to the log file
  	  echo "ndctl Output:" >> "$log_file"
	  echo "===============" >> "$log_file"
          ndctl list -N >> "$log_file"
          ndctl list -R >> "$log_file"
	fi

	# Save df output to the log file
	echo "df Output:" >> "$log_file"
	echo "==========" >> "$log_file"
	df -h >> "$log_file"
	echo "" >> "$log_file"  # Add an empty line for better readability
	
	# Check if OMP_DISPLAY_ENV is set to true
	if [ "$OMP_DISPLAY_ENV" = "true" ]; then
	  # Save OpenMP environment variables with their values to the log file with a title
	  echo "OpenMP Environment Variables:" >> "$log_file"
	  echo "============================" >> "$log_file"
	  env | grep ^OMP >> "$log_file"
	fi



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
                if [[ memory == *DAX* ]]; then
                    rm -rf "$dax_path/pool.obj"
                fi
        done
        column -t -s "," "$tmp_csv"
        echo "Output data saved in $tmp_csv"
	python3 plot_results.py "$input_dir/$dir"
        git add $input_dir
        git commit -m "Update results for backup"
        git push origin main
    done
else
echo "Input Directory not found: $input_dir"
fi
