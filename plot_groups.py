import os
import sys
import csv
import matplotlib.pyplot as plt

def read_data(file_path):
    x_values = []
    y_values = [[] for _ in range(4)]  # One list for each method

    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            x_values.append(float(row[0]))
            for i in range(4):
                y_values[i].append(float(row[i + 1]))

    return x_values, y_values

def get_color_and_marker(subdir):
    colors = {
        ("Socket0", "Socket0DDR4DAX"): '#FFCC99',
        ("Socket1", "Socket1DDR4DAX"): '#FFCC99',
        ("Socket0", "Socket1DDR4DAX"): '#994C00',
        ("Socket1", "Socket0DDR4DAX"): '#994C00',
        ("Socket0Socket1", "Socket0DDR4DAX"): '#EB6E00',
        ("Socket0Socket1", "Socket1DDR4DAX"): '#FFAC3D',

        ("Socket0", "Socket0DDR5DAX"): '#FFCC99',
        ("Socket1", "Socket1DDR5DAX"): '#FFCC99',
        ("Socket0", "Socket1DDR5DAX"): '#994C00',
        ("Socket1", "Socket0DDR5DAX"): '#994C00',
        ("Socket0Socket1", "Socket0DDR5DAX"): '#EB6E00',
        ("Socket0Socket1", "Socket1DDR5DAX"): '#FFAC3D',

        ("Socket0", "Socket0DDR4"): '#336600',
        ("Socket1", "Socket1DDR4"): '#336600',
        ("Socket0", "Socket1DDR4"): '#03B95E',
        ("Socket1", "Socket0DDR4"): '#03B95E',
        ("Socket0Socket1", "Socket0DDR4"): '#42D502',
        ("Socket0Socket1", "Socket1DDR4"): '#CCCC00',


        ("Socket0", "Socket0DDR5"): '#336600',
        ("Socket1", "Socket1DDR5"): '#336600',
        ("Socket0", "Socket1DDR5"): '#03B95E',
        ("Socket1", "Socket0DDR5"): '#03B95E',
        ("Socket0Socket1", "Socket0DDR5"): '#42D502',
        ("Socket0Socket1", "Socket1DDR5"): '#CCCC00',

        ("Socket0", "Socket0OptaneDAX"): '#E89C9C',
        ("Socket1", "Socket1OptaneDAX"): '#E89C9C',
        ("Socket0", "Socket1OptaneDAX"): '#920000',
        ("Socket1", "Socket0OptaneDAX"): '#920000',
        ("Socket0Socket1", "Socket0OptaneDAX"): '#FF4242',
        ("Socket0Socket1", "Socket1OptaneDAX"): '#CA0303',

        ("Socket0", "CXLDDR4"): '#990099',
        ("Socket1", "CXLDDR4"): '#FF00FF',
        ("Socket0Socket1", "CXLDDR4"): '#FF007F',
        ("Socket0", "CXLDAX"): '#3399FF',
        ("Socket1", "CXLDAX"): '#0000CC',
        ("Socket0Socket1", "CXLDAX"): '#33FFFF'
    }

    markers = {
        ("Spread", "noFT"): 'x',
        ("Spread", "FT"): '*',
        ("Close", "noFT"): '^',
        ("Close", "FT"): 'v'
    }

    subdir_values = subdir.split('_')
    ht = subdir_values[0] if len(subdir_values) > 0 else "ht"
    cores = subdir_values[1] if len(subdir_values) > 1 else "cores"
    memory = subdir_values[2] if len(subdir_values) > 2 else "memory"
    affinity = subdir_values[3] if len(subdir_values) > 3 else "affinity"
    ft = subdir_values[4] if len(subdir_values) > 4 else "ft"

    color_key = (cores, memory)

    marker_key = (affinity, ft)

    color = colors.get(color_key, 'green')
    marker = markers.get(marker_key, 'o')

    return color, marker

def plot_graphs(directory):
    methods = ["Copy", "Scale", "Add", "Triad"]

    for method_index, method in enumerate(methods):
        plt.figure(figsize=(12, 8))  # Increase the width of the x-axis
        plt.title(f"{method} Rates")
        plt.xlabel("Number of Threads")
        plt.ylabel("Rate (MB/s)")
        for subdir in os.listdir(directory):
            subdir_path = os.path.join(directory, subdir)
            if os.path.isdir(subdir_path):
                data_file_path = os.path.join(subdir_path, "output_data.csv")
                if os.path.exists(data_file_path):
                    x_values, y_values = read_data(data_file_path)
                    color, marker = get_color_and_marker(subdir)
                    subdir_name = '_'.join(subdir.split('_')[:-2])  # Get the dir name without the first two elements
                    label = f"{subdir_name}"
                    plt.plot(x_values, y_values[method_index], label=label, color=color, marker=marker)

        plt.ylim(0, 25000)  # Set the maximum value of the y-axis to 25000
        plt.grid(True)
        plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.2), ncol=3)
        plt.savefig(os.path.join(directory, f"{method}_plot.svg"), bbox_inches='tight')
        plt.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py directory_name")
    else:
        input_directory = sys.argv[1]
        plot_graphs(input_directory)

