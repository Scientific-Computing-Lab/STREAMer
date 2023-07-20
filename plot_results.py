import csv
import matplotlib.pyplot as plt
import sys


def plot(path):
	# Initialize empty lists to store data
	number_of_threads = []
	copy_rate = []
	scale_rate = []
	add_rate = []
	triad_rate = []

	# Read data from CSV file
	with open(path+'/output_data.csv', 'r') as file:
	    reader = csv.reader(file)
	    next(reader)  # Skip header row
	    for row in reader:
	        # Extract data from each row
	        thread_count = int(row[0])
        	copy = float(row[1])
        	scale = float(row[2])
       		add = float(row[3])
        	triad = float(row[4])
        	# Append data to respective lists
        	number_of_threads.append(thread_count)
        	copy_rate.append(copy)
        	scale_rate.append(scale)
        	add_rate.append(add)
        	triad_rate.append(triad)

    	# Create plot
	plt.plot(number_of_threads, copy_rate, label='Copy Rate')
	plt.plot(number_of_threads, scale_rate, label='Scale Rate')
	plt.plot(number_of_threads, add_rate, label='Add Rate')
	plt.plot(number_of_threads, triad_rate, label='Triad Rate')
       
    	# Set plot labels and title
	plt.xlabel('Number of Threads')
	plt.ylabel('Rate (MB/s)')
	#plt.title('STREAM Performance Rates')
	# Add legend
	plt.legend()
	plt.tight_layout()
	# Save the plot as an SVG image
	plt.savefig(path+'/graph_results.svg', format='svg')
	print("plot saved in " + path + "/graph_results.svg")
 	# Display the plot
	plt.show()

if __name__ == "__main__":
	if len(sys.argv) !=2:
		print("Need to provide relative path to directory with csv file")
		sys.exit(1)

	path=sys.argv[1]
	plot(path)
