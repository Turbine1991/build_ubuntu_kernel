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

#Retrieves the latest file/dir from a generated apache index page containing given string
function get_http_apache_listing {
  local http_request=$1
  local http_match=$2

  if [[ "$3" ]]; then
    local str_http_head=$3
  fi

  local http_items=$(curl "$http_request/?C=M;O=D" 2> /dev/null \
                | grep "<a href=" \
                | grep -v 'Parent Directory' \
                | sed "s/<a href/\\n<a href/g" \
                | sed 's/\"/\"><\/a>\n/2' \
                | grep href \
                | awk '{ print $2 }' \
                | cut -d '"' -f2 \
                | grep "$http_match" \
                | sed -e 's/^\///' \
                | sed -e 's#/$##' \
                | grep -v '?' \
                | head -$str_http_head )

  echo "$http_items"
}

#Returns a boolean 1 or 0, on the condition of a matching string value
function match_str {
  local result=`echo $1 | grep $2`

  if [[ -z "$3" ]]; then
    [[ $result ]] && echo 1 || echo 0
  else
    [[ $result ]] && echo $3
  fi
}

#Outputs a files contents omitting commented lines
function cat_contents {
  local filename=$1

  #cat "$filename" | egrep -v "^\s*(#|$)"
  awk '!/^ *#/ && NF' "$filename"
}
