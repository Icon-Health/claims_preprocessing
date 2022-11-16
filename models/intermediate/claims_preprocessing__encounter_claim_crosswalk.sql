-------------------------------------------------------------------------------
-- Author       Thu Xuan Vu
-- Created      June 2022
-- Purpose      Create a crosswalk from encounter_id to claim_id
-- Notes        
-------------------------------------------------------------------------------
-- Modification History
-- 09/28/2022 Thu Xuan Vu
--      Changed references of merge_claim_id to claim_id
-- 11/01/2022 Thu Xuan Vu
--      Creating encounter id for vision and dental claims
-------------------------------------------------------------------------------
{{ config(
    tags=["medical_claim"]
    ,enabled=var('claims_preprocessing_enabled',var('tuva_packages_enabled',True))
) }}
/** Institutional merged  **/

select
  c.group_claim_id as encounter_id
  ,d.claim_id
  ,'inst merge' as merge_type
from {{ ref('claims_preprocessing__encounter_type_union')}} d
inner join {{ ref('claims_preprocessing__inst_merge_crosswalk')}} c
    on d.claim_id = c.claim_id

union

/**  Institutional non-merged  **/

select
  c.encounter_id
  ,c.encounter_id as claim_id
  ,'inst nonmerge' as merge_type
from  {{ ref('claims_preprocessing__inst_encounter_nonmerge')}} c


union
/**  Professional linked to institutional  **/
select 
  encounter_id
  ,claim_id
  ,'prof linked to inst merge' as merge_type
from {{ ref('claims_preprocessing__prof_inst_encounter_crosswalk')}}

union

/** Professional merged  **/
select 
  d.encounter_id
  ,d.claim_id
  ,'prof merge' as merge_type
from {{ ref('claims_preprocessing__prof_merge_final')}} d

union
/**  Professional nonmerged claims  **/
select 
  d.claim_id as encounter_id
  ,d.claim_id
    ,'prof nonmerge' as merge_type
from {{ ref('claims_preprocessing__encounter_type_union')}} d
left join {{ ref('claims_preprocessing__prof_merge_final')}} c
    on d.claim_id = c.claim_id
left join {{ ref('claims_preprocessing__prof_inst_encounter_crosswalk')}} i
    on i.claim_id = d.claim_id
where d.claim_type = 'professional'
and c.claim_id is null
and i.claim_id is null

union
/**  Professional nonmerged claims  **/
select 
  d.claim_id as encounter_id
  ,d.claim_id
  ,'other claim type nonmerge' as merge_type
from {{ ref('claims_preprocessing__encounter_type_union')}} d
where d.claim_type in ('vision','dental')


