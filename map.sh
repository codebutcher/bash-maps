function extract(){
	echo $@ | sed -e 's/^\([a-z_0-9].*\)\[\(.*\)\]=\?\(.*\)/\1 \2 \3/gi'
}
function printmap(){
	local map="$1"
	 echo $(eval echo `echo \\\$$map`)
}
function mapget(){
	local mapname=$1;
	local key=$2
	local map=`printmap $mapname`
	echo $map | grep "$key:" > /dev/null &&  echo $map | sed -e "s/^\(.*;\)\?$key:\([^;]*\).*/\2/"
}
function mapdel(){
    local mapname=$1;
	local key=$2
    local map=`printmap $mapname`
	eval $mapname=\"`echo $map | sed -e "s/^\(.*;\)\?$key:[^;]*;/\1/"`\"
}
function mapadd(){
	local mapname=$1;
	local key=$2;
	local val="$3"
    local map=`printmap $mapname`
	eval "${mapname}=\"$map$key:$val;\""
}
function mapreplace(){
	local mapname=$1;
	local key=$2;
	local val=$3
    local map=`printmap $mapname`
	local newmap="`echo $map | sed -e \"s/$key:[^;]*/$key:$val/g\"`"
	eval $mapname=\"$newmap\"
}
function map(){
	
	read mapname key val <<< $(extract $@)
	local mapname="map_$mapname"
	# map del
	if echo $1  | grep "^del"  > /dev/null; then
		read mapname key val <<< $(shift; extract $@)
		local mapname="map_$mapname"
		mapdel $mapname $key

	# map add
	elif echo $1  | grep "="  > /dev/null; then
		if [ -z "`mapget $mapname $key`" ]; then
			mapadd $mapname $key "$val"
		else 
			mapreplace $mapname $key "$val"
		fi
	# map get	
	elif echo $1 | grep "\]"  > /dev/null; then 
		mapget $mapname $key
	# map iterate get
	else
		printmap $mapname | sed  -e 's/\;$//' | sed -e  "s/;/\n/g"  | awk -F":" '{ print "\""$1"\" \""$2"\"" }'
	fi
}
