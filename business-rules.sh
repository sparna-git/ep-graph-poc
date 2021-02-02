rules=( 
	"02-Dataset2_MEP/10-Rules/business-rule-2"
  "02-Dataset2_MEP/10-Rules/business-rule-3"
	"02-Dataset2_MEP/10-Rules/business-rule-4"
	"03-Dataset3_Sessions/10-Rules/business-rule-1"
	"04-Dataset4_Votes/10-Rules/business-rule-1"
	"04-Dataset4_Votes/10-Rules/business-rule-2"
	"04-Dataset4_Votes/10-Rules/business-rule-3"
  "04-Dataset4_Votes/10-Rules/business-rule-4"
  "04-Dataset4_Votes/10-Rules/business-rule-5"
)

for ruleDirectory in "${rules[@]}"
do
  echo "${ruleDirectory}"
  # do something on $ruleDirectory
  java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar validate \
  	-s $ruleDirectory/business-rule.ttl \
  	-i $ruleDirectory/test-data.ttl \
  	-i $ruleDirectory/input \
  	-o $ruleDirectory/report.html \
  	-o $ruleDirectory/report-raw.html \
  	-o $ruleDirectory/report.ttl
done