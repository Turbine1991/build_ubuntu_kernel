#Functions
function sa_get_count() {
  local str="$1"
  echo $(echo "$str" | wc -w)
}

function sa_get_value() {
  local str="$1"
  local str_arr=($str)
  local index="$2"

  echo ${str_arr[$index]}
}

function sa_sort() {
  arr=($1)
  IFS=$'\n' sorted=($(sort <<<"${arr[*]}"))
  printf "%s\n" "${sorted[@]}"
}

function sa_reverse() {
  local str="$1"
  local output=""

  for value in $str; do
    echo "$value";
  done | tac
}

function get_git_branches() {
  local link="$1"
  local output=""

  rm -R temp
  git clone "$link" temp
  cd temp
  branches=$(git branch -a | grep "linux-" | cut -d- -f2)
  cd ..
  rm -R temp

  for branch in $branches
  do
    output="$output$branch "
  done

  echo "$output"
}

function print_choices() {
  local branches="$1"
  local branch=""

  local i=1
  for branch in $branches
  do
    printf "%i) %s\n" $i $branch
    ((i++))
  done
}
