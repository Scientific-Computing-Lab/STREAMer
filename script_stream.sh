#!/bin/bash

dir=check_node
threads=($(seq 1 40))
#compile -----------------------------------------------------------------
gcc -fopenmp -lpmemobj -lpmem -O -DSTREAM_ARRAY_SIZE=100000000 -D_OPENMP stream_pmemobj.c -o stream_pmemobj
#gcc -fopenmp -O -DSTREAM_ARRAY_SIZE=100000000 -D_OPENMP stream.c -o stream
#-------------------------------------------------------------------------
tmp_csv="$dir/output_data.csv"
echo "Number of Threads,Copy Rate (MB/s),Scale Rate (MB/s),Add Rate (MB/s),Triad Rate (MB/s)" > "$tmp_csv"
for thread in "${threads[@]}"; do

                export OMP_NUM_THREADS=$thread
                output_file=$"$dir/output.$thread.txt"
                ./stream_pmemobj > $output_file
                #numactl --membind=1 --cpunodebind=0 ./stream > $output_file
                #numactl --cpunodebind=0 ./stream_pmemobj > $output_file
                copy_rate=$(grep "Copy:" "$output_file" | awk '{print $2}')
                scale_rate=$(grep "Scale:" "$output_file" | awk '{print $2}')
                add_rate=$(grep "Add:" "$output_file" | awk '{print $2}')
                triad_rate=$(grep "Triad:" "$output_file" | awk '{print $2}')

                echo "$thread,$copy_rate,$scale_rate,$add_rate,$triad_rate" >> "$tmp_csv"

                # Clean the cache
                #   sudo sync; echo 1 > /proc/sys/vm/drop_caches

                echo DONE $thread threads
        done
        column -t -s "," "$tmp_csv"
        echo "Output data saved in $tmp_csv"
