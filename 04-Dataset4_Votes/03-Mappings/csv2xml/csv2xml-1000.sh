export INPUT_FOLDER=$1
export OUTPUT_FOLDER=$2

for f in $(find $INPUT_FOLDER -name '*.csv'); do 
	echo "Converting $f to XML"
	mkdir --parent $OUTPUT_FOLDER/$(dirname "${f}")
	python csv2xml.py $f > $OUTPUT_FOLDER/$(dirname "${f}")/$(basename "$f" | cut -d. -f1).xml 1000
done