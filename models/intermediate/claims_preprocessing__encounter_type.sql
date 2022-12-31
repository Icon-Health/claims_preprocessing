
{{ config(
     enabled = var('claims_preprocessing_enabled',var('tuva_packages_enabled',True))
   )
}}


with unmapped as (
    select distinct claim_id
    from {{ ref('claims_preprocessing__medical_claim') }}
    where claim_id not in (select claim_id from {{ref ('intermediate_encounter_type_temp') }} )
),


encounter_types as (
    select
    claim_id,
    encounter_type,
    encounter_type_detail
    from {{ref ('intermediate_encounter_type_temp') }} )

    union all

    select
    claim_id,
    'unmapped' as encounter_type,
    'unmapped' as encounter_type_detail
    from unmapped
)

select * from encounter_types