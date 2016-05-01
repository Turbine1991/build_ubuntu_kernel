#Disables all hyper-threaded cores, for potentially better scheduling with WastedCores
#Run after every reboot
#Only works on single-processor systems

enable=${1:-1}

function get_cpuval() {
  echo $(lscpu | grep -e "$1" | awk -v place=$2 '{ print $place }')
}

if [[ `get_cpuval "^Socket(s):" 2` == "1" ]]; then
  cores=$(get_cpuval "^CPU(s):" 2)
  cores_actual=$(get_cpuval "^Core(s) per socket:" 4)

  if [[ cores != cores_actual ]]; then
    ht_cores_min=$cores_actual
    ht_cores_max=$(($cores_actual * 2 - 1))

    for ((i = $ht_cores_min; i <= $ht_cores_max; i++)); do
      (( $enable )) && flag=0 || flag=1
      output="echo $flag > /sys/devices/system/cpu/cpu$i/online"
      bash -c "$output"
      echo "$output"
    done
  fi
fi
