#!/bin/bash

# We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
# Checking for the specified output directory.   If it exists, check for a pe_quick_data directory and create it if not present.
# Set the variable output_dir to user specified output directory plus pe_quick_data directory to avoid issues when zipping and deleting files
# We're exiting out of this script if no gzip files exist, or if there is no output directory
if [ -d $PT_output_dir ]
then
    if [ ! -d "$PT_output_dir/pe_quick_data" ]
    then
        mkdir -p "$PT_output_dir/pe_quick_data"
        output_dir="$PT_output_dir"
        output_dir+="/"
        output_dir+="pe_quick_data"
    else
        output_dir="$PT_output_dir"
        output_dir+="/"
        output_dir+="pe_quick_data"
    fi

    count=$(ls -1 "$output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        echo "gz file found for adding node data to"
    else
        echo "No gzip files available to use for adding node data"
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
    exit
fi

# See if there is already a pe_resources directory in the output directory and if not let's create it
if [ ! -d "$output_dir/pe_resources/" ]
then
    mkdir -p "$output_dir/pe_resources/"
fi

resrcs_by_cert_file="$output_dir/pe_resources/resources_by_certname.json"
resrcs_total_file="$output_dir/pe_resources/resources_total.json"

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

echo " ** Collecting Output of: Number of Resources by Certname"
echo ""

# Get the total number of resource being utilized in the environment and get the number of resources by node
puppet query "resources[count()] {}" > $resrcs_total_file
puppet query "resources[certname, count()] { group by certname }" > $resrcs_by_cert_file