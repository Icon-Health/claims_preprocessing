

{{ config(
     enabled = var('claims_preprocessing_enabled',var('tuva_packages_enabled',True))
   )
}}




select *
from `ferrous-weaver-306014.primus_connector.medical_claim`


