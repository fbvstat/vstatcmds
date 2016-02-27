#!/bin/bash

#Internal Field Separator
IFS=$'\n'
pushd `dirname $0` > /dev/null
parent_directory=`pwd`
popd > /dev/null
hash_ext=".md5"
hash_bin="md5sum"
HASH_FILE_TEMPLATE="$parent_directory/checksumm/%SCRIPT_NAME%${hash_ext}"
do_list="do.list"
ADM_PRIV_PREFIX="/bin/bash"

#####set array
declare flag_names=( "{run_once}" "{adm_priv}" )
#####Instruction loop of script names
for line in `cat do.list`; do
	#create command line to run
	script_name=`echo $line | awk '{print $1}'`
	cmd="$parent_directory/$script_name"
	param_count=$((`echo $line | wc -w` -1))

	#<if no parameteres>
	if [ $param_count -eq 0 ]; then
		eval $cmd
		continue
	fi
	#</if no parameteres>
	
	#<Check provided flags>
	declare -A flags
	for flag_name in ${flag_names[@]}; do
		flag_name=`echo $flag_name | tr -d "{}"`
		flags[$flag_name]=`echo $line | grep -c $flag_name`
	done
	#</Check provided flags>

	#<if run_once flag provided>
	if [ ${flags[run_once]} -ne 0 ]; then
		hash_file=`echo $HASH_FILE_TEMPLATE | sed "s/%SCRIPT_NAME%/$script_name/g"`
		old_hash=`cat $hash_file | awk '{print $1}'`
		new_hash=`$hash_bin $script_name | awk '{print $1}'`
		if [ "$new_hash" == "$old_hash" ]; then
			continue
		else 
			echo $new_hash > $hash_file
		fi
	fi
	#</if run_once flag provided

	#if adm_priv flag provided
	if [ ${flags[adm_priv]} -ne 0 ]; then
		cmd="$ADM_PRIV_PREFIX $cmd"
	fi
	#</if run_once flag provided>
	
	#<run>
	eval $cmd
	#</run>
done
