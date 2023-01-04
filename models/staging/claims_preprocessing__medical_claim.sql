

{{ config(
     enabled = var('claims_preprocessing_enabled',var('tuva_packages_enabled',True))
   )
}}




select *
from `fiery-pipe-330412.auxilium_connector.medical_claim`


