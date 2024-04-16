#!/bin/bash
#
# Script version and author information
VERSION="1.0.0"
AUTHOR="Rajesh Prashanth A <rajeshprasanth@rediffmail.com>"
#
#
# Function to parse command-line options
# Usage: parse_options "$@"
parse_options() {
    # Parse command-line options using getopt
    args=$(getopt -o s:p:f:o: --long strain:,strain-percentage:,poscar:,output-dir: -n "$0" -- "$@")

    # Check for parsing errors
    if [ $? -ne 0 ]; then
        echo "Error: Invalid command-line options"
        display_usage
        exit 1
    fi


    # Extract options and their arguments into variables
    eval set -- "$args"
    while true; do
        case "$1" in
            -s | --strain)
                strain_direction="$2"
                shift 2
                ;;
            -p | --strain-percentage)
                strain_percentage="$2"
                shift 2
                ;;
            -f | --poscar)
                poscar_filename="$2"
                shift 2
                ;;
            -o | --output-dir)
                output_dir="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Internal error!"
                exit 1
                ;;
        esac
    done

    # Display help message if any required options are missing
    if [ -z "$strain_direction" ] || [ -z "$strain_percentage" ] || [ -z "$poscar_filename" ] || [ -z "$output_dir" ]; then
        echo "Error: Missing required options"
        display_usage
        exit 1
    fi


}


# Function to display usage instructions
display_usage() {
    echo "Usage: $0 -s <strain_direction> -p <strain_percentage> -f <poscar_filename> -o <output_dir>"
    echo "Options:"
    echo "  -s, --strain            Direction of the strain (x, y, or z)"
    echo "  -p, --strain-percentage Strain percentage to apply"
    echo "  -f, --poscar            Path to the POSCAR file"
    echo "  -o, --output-dir        Path to the output directory"
}

# Function to display version information
display_version() {
    echo "$0 version $VERSION, created by $AUTHOR"
}

# Main script starts here

# Parse command-line options
parse_options "$@"

# Now you can use $strain_direction, $strain_percentage, $poscar_filename, and $output_dir variables in your script
