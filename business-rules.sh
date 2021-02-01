rules=( 
	"02-Dataset2_MEP/10-Rules/business-rule-1"
	"02-Dataset2_MEP/10-Rules/business-rule-2"
)

for ruleDirectory in "${rules[@]}"
do
  echo "${ruleDirectory}"
  # do something on $var
  java -jar shacl-play-app-0.4-onejar.jar validate -s $ruleDirectory/business-rule.ttl -i $ruleDirectory/test-data.ttl -o $ruleDirectory/report.html -o $ruleDirectory/report-raw.html -o $ruleDirectory/report.ttl
done