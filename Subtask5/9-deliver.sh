# split translation activities in document dataset
java -jar saxon-he-10.1.jar \
	-s:04-eli-dl-ap-ep-documents/05-RDF/export-REPORTandAM.rdf \
	-xsl:04-eli-dl-ap-ep-documents/03-XSLT/split-translations.xsl \
	-o:04-eli-dl-ap-ep-documents/05-RDF/dummy.xml


# create delivery folder
export DELIVERY_FOLDER=delivery

rm -rf $DELIVERY_FOLDER
mkdir $DELIVERY_FOLDER
mkdir -p $DELIVERY_FOLDER/00-cv/RDF
mkdir -p $DELIVERY_FOLDER/00-cv/SHACL
mkdir -p $DELIVERY_FOLDER/00-cv/SHACL-REPORT
mkdir -p $DELIVERY_FOLDER/01-org-ap-ep/RDF
mkdir -p $DELIVERY_FOLDER/01-org-ap-ep/SHACL
mkdir -p $DELIVERY_FOLDER/01-org-ap-ep/SHACL-REPORT
mkdir -p $DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/RDF
mkdir -p $DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL
mkdir -p $DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL-REPORT
mkdir -p $DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/RDF
mkdir -p $DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL
mkdir -p $DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL-REPORT
mkdir -p $DELIVERY_FOLDER/04-translations/RDF
mkdir -p $DELIVERY_FOLDER/04-translations/SHACL
mkdir -p $DELIVERY_FOLDER/04-translations/SHACL-REPORT
mkdir -p $DELIVERY_FOLDER/05-inferences/SPARQL
mkdir -p $DELIVERY_FOLDER/05-inferences/RDF

# CVs
cp 01-cv/05-RDF/* 					$DELIVERY_FOLDER/00-cv/RDF
cp 01-cv/04-SHACL/* 				$DELIVERY_FOLDER/00-cv/SHACL
cp 01-cv/20-SHACL_TTL/* 			$DELIVERY_FOLDER/00-cv/SHACL
cp 01-cv/21-DOCUMENTATION/* 		$DELIVERY_FOLDER/00-cv/SHACL
cp 01-cv/20-REPORT/* 				$DELIVERY_FOLDER/00-cv/SHACL-REPORT

# ORGs
cp 02-org-ap-ep/05-RDF/* 			$DELIVERY_FOLDER/01-org-ap-ep/RDF
cp 02-org-ap-ep/04-SHACL/* 			$DELIVERY_FOLDER/01-org-ap-ep/SHACL
cp 02-org-ap-ep/20-SHACL_TTL/* 		$DELIVERY_FOLDER/01-org-ap-ep/SHACL
cp 02-org-ap-ep/21-DOCUMENTATION/* 	$DELIVERY_FOLDER/01-org-ap-ep/SHACL
cp 02-org-ap-ep/20-REPORT/* 		$DELIVERY_FOLDER/01-org-ap-ep/SHACL-REPORT

# Activities
cp 03-eli-dl-ap-ep-activities/05-RDF/* 				$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/RDF
cp 03-eli-dl-ap-ep-activities/04-SHACL/* 			$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL
cp 03-eli-dl-ap-ep-activities/20-SHACL_TTL/* 		$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL
cp 03-eli-dl-ap-ep-activities/21-DOCUMENTATION/* 	$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL
cp 03-eli-dl-ap-ep-activities/20-REPORT/* 			$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/SHACL-REPORT
## special : translation activities
cp 04-eli-dl-ap-ep-documents/05-RDF/translation-activities.rdf	$DELIVERY_FOLDER/02-eli-dl-ap-ep-activities/RDF

# Documents
## special : translation activities
cp 04-eli-dl-ap-ep-documents/05-RDF/export-REPORTandAM-documents.rdf $DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/RDF
cp 04-eli-dl-ap-ep-documents/05-RDF/export-draftRPandAM.rdf $DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/RDF
cp 04-eli-dl-ap-ep-documents/04-SHACL/* 			$DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL
cp 04-eli-dl-ap-ep-documents/20-SHACL_TTL/* 		$DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL
cp 04-eli-dl-ap-ep-documents/21-DOCUMENTATION/* 	$DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL
cp 04-eli-dl-ap-ep-documents/20-REPORT/* 			$DELIVERY_FOLDER/03-eli-dl-ap-ep-documents/SHACL-REPORT

# Translations
cp 05-translations/05-RDF/* 						$DELIVERY_FOLDER/04-translations/RDF
cp 05-translations/04-SHACL/* 						$DELIVERY_FOLDER/04-translations/SHACL
cp 05-translations/20-SHACL_TTL/* 					$DELIVERY_FOLDER/04-translations/SHACL
cp 05-translations/21-DOCUMENTATION/* 				$DELIVERY_FOLDER/04-translations/SHACL
cp 05-translations/20-REPORT/* 						$DELIVERY_FOLDER/04-translations/SHACL-REPORT

# Inferences
cp 06-inferences/05-RDF/*							$DELIVERY_FOLDER/05-inferences/RDF
cp 06-inferences/01-SPARQL/*						$DELIVERY_FOLDER/05-inferences/SPARQL