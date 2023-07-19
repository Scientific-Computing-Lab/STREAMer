import argparse
import os

# Create the parser
parser = argparse.ArgumentParser(description='Program Options')

# Hyperthreading option
ht_group = parser.add_mutually_exclusive_group()
ht_group.add_argument('--noHT', action='store_true', help='Disable hyperthreading')
ht_group.add_argument('--HT', action='store_true', help='Enable hyperthreading')

# Cores option
cores_group = parser.add_mutually_exclusive_group()
cores_group.add_argument('--Socket0', action='store_true', help='Use only Socket0 cores')
cores_group.add_argument('--Socket1', action='store_true', help='Use only Socket1 cores')
cores_group.add_argument('--Socket0Socket1', action='store_true', help='Use both Socket0 and Socket1 cores')

# Memory option
memory_group = parser.add_mutually_exclusive_group()
memory_group.add_argument('--Socket0DDR4', action='store_true', help='Use DDR4 memory on Socket0')
memory_group.add_argument('--Socket1DDR4', action='store_true', help='Use DDR4 memory on Socket1')
memory_group.add_argument('--CXLDDR4', action='store_true', help='Use DDR4 memory with CXL')
memory_group.add_argument('--Socket0DDR5', action='store_true', help='Use DDR5 memory on Socket0')
memory_group.add_argument('--Socket1DDR5', action='store_true', help='Use DDR5 memory on Socket1')
memory_group.add_argument('--CXLDAX', action='store_true', help='Use DAX DDR4 memory with CXL')
memory_group.add_argument('--Socket0DDR4DAX', action='store_true', help='Use DAX DDR4 memory on Socket0')
memory_group.add_argument('--Socket1DDR4DAX', action='store_true', help='Use DAX DDR4 memory on Socket1')
memory_group.add_argument('--Socket0DDR5DAX', action='store_true', help='Use DAX DDR5 memory on Socket0')
memory_group.add_argument('--Socket1DDR5DAX', action='store_true', help='Use DAX DDR5 memory on Socket1')

# Thread Affinity option
affinity_group = parser.add_mutually_exclusive_group()
affinity_group.add_argument('--Close', action='store_true', help='Use close thread affinity')
affinity_group.add_argument('--Spread', action='store_true', help='Use spread thread affinity')

# First Touch option
ft_group = parser.add_mutually_exclusive_group()
ft_group.add_argument('--noFT', action='store_true', help='Disable first touch')
ft_group.add_argument('--FT', action='store_true', help='Enable first touch')

# DAX Path option
parser.add_argument('--DAX_Path', type=str, default='NOPATH', help='Path for DAX (default: {NOPATH})')

# Additional variables
default_arrays_size = 100000000
default_cores_per_socket = 10

# Add the variables as command-line arguments
parser.add_argument('--Arrays_Size', type=int, default=default_arrays_size,
                    help=f'Specify the size of the arrays (default: {default_arrays_size})')
parser.add_argument('--Cores_per_Socket', type=int, default=default_cores_per_socket,
                    help=f'Specify the number of cores per socket (default: {default_cores_per_socket})')


# Parse the command-line arguments
args = parser.parse_args()

# Set the defaults for each group if no other option in the group was chosen
if not args.noHT and not args.HT:
    args.noHT = True

if not args.Socket0 and not args.Socket1 and not args.Socket0Socket1:
    args.Socket0 = True

if not args.Socket0DDR4 and not args.Socket1DDR4 and not args.CXLDDR4 and not args.Socket0DDR5 and not args.Socket1DDR5 and not args.CXLDAX and not args.Socket0DDR4DAX and not args.Socket1DDR4DAX and not args.Socket0DDR5DAX and not args.Socket1DDR5DAX:
    args.Socket0DDR4 = True

if not args.Close and not args.Spread:
    args.Close = True

if not args.noFT and not args.FT:
    args.noFT = True



# Access the selected options
if args.noHT:
    print('Hyperthreading is disabled')
elif args.HT:
    print('Hyperthreading is enabled')

if args.Socket0:
    print('Using only Socket0 cores')
elif args.Socket1:
    print('Using only Socket1 cores')
elif args.Socket0Socket1:
    print('Using both Socket0 and Socket1 cores')

if args.Socket0DDR4:
    print('Using DDR4 memory on Socket0')
elif args.Socket1DDR4:
    print('Using DDR4 memory on Socket1')
elif args.CXLDDR4:
    print('Using DDR4 memory with CXL')
elif args.Socket0DDR5:
    print('Using DDR5 memory on Socket0')
elif args.Socket1DDR5:
    print('Using DDR5 memory on Socket1')
elif args.CXLDAX:
    print('Using DAX DDR4 memory with CXL')
elif args.Socket0DDR4DAX:
    print('Using DAX DDR4 memory on Socket0')
elif args.Socket1DDR4DAX:
    print('Using DAX DDR4 memory on Socket1')
elif args.Socket0DDR5DAX:
    print('Using DAX DDR5 memory on Socket0')
elif args.Socket1DDR5DAX:
    print('Using DAX DDR5 memory on Socket1')

if args.Close:
    print('Using close thread affinity')
elif args.Spread:
    print('Using spread thread affinity')

if args.noFT:
    print('First touch is disabled')
elif args.FT:
    print('First touch is enabled')

# Create the folder name based on the arguments
folder_name = ''

if args.noHT or args.HT:
    folder_name += 'noHT_' if args.noHT else 'HT_'

if args.Socket0 or args.Socket1 or args.Socket0Socket1:
    if args.Socket0:
        folder_name += 'Socket0_'
    elif args.Socket1:
        folder_name += 'Socket1_'
    elif args.Socket0Socket1:
        folder_name += 'Socket0Socket1_'

if args.Socket0DDR4 or args.Socket1DDR4 or args.CXLDDR4 or args.Socket0DDR5 or args.Socket1DDR5 or args.CXLDAX or args.Socket0DDR4DAX or args.Socket1DDR4DAX or args.Socket0DDR5DAX or args.Socket1DDR5DAX:
    if args.Socket0DDR4:
        folder_name += 'Socket0DDR4_'
    elif args.Socket1DDR4:
        folder_name += 'Socket1DDR4_'
    elif args.CXLDDR4:
        folder_name += 'CXLDDR4_'
    elif args.Socket0DDR5:
        folder_name += 'Socket0DDR5_'
    elif args.Socket1DDR5:
        folder_name += 'Socket1DDR5_'
    elif args.CXLDAX:
        folder_name += 'CXLDAX_'
    elif args.Socket0DDR4DAX:
        folder_name += 'Socket0DDR4DAX_'
    elif args.Socket1DDR4DAX:
        folder_name += 'Socket1DDR4DAX_'
    elif args.Socket0DDR5DAX:
        folder_name += 'Socket0DDR5DAX_'
    elif args.Socket1DDR5DAX:
        folder_name += 'Socket1DDR5DAX_'

if args.Close or args.Spread:
    folder_name += 'Close_' if args.Close else 'Spread_'

if args.noFT or args.FT:
    folder_name += 'noFT_' if args.noFT else 'FT_'

if args.DAX_Path:
    folder_name += args.DAX_Path.replace("/", "@")+'_'

# Add Arrays_Size and Cores_per_Socket to the folder name
folder_name += f'Arrays{args.Arrays_Size}_Cores{args.Cores_per_Socket}/'

# Create the folder
if folder_name:
    os.makedirs(folder_name)
    print(f"Folder '{folder_name}' has been created.")
else:
    print("No folder needs to be created.")

