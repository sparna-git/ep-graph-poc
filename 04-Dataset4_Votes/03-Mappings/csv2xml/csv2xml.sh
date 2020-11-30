export INPUT_FOLDER=$1
export OUTPUT_FOLDER=$2

for f in $(find $INPUT_FOLDER -name '*.csv'); do
	DIRNAME=$(dirname "${f#*/}")
	# remove first / from DIRNAME
	XML_FOLDER=$OUTPUT_FOLDER/${DIRNAME#*/}
	XML_FILE=$XML_FOLDER/$(basename "$f" | cut -d. -f1).xml
	echo "Converting $f to $XML_FILE"
	mkdir --parent $XML_FOLDER
	python csv2xml.py $f > $XML_FILE
done