

{{ config(
     enabled = var('claims_preprocessing_enabled',var('tuva_packages_enabled',True))
   )
}}

-- *************************************************
-- This dbt model assigns an encounter type to every
-- unique claim_id in the medical_claim table.
-- *************************************************




-- Lists unique claim_ids with 'Room & Board'
-- revenue_center_codes:
with room_and_board as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code in
  ('0100','0101',
   '0110','0111','0112','0113','0114','0116','0117','0118','0119',
   '0120','0121','0122','0123','0124','0126','0127','0128','0129',
   '0130','0131','0132','0133','0134','0136','0137','0138','0139',
   '0140','0141','0142','0143','0144','0146','0147','0148','0149',
   '0150','0151','0152','0153','0154','0156','0157','0158','0159',
   '0160','0164','0167','0169',
   '0170','0171','0172','0173','0174','0179',
   '0190','0191','0192','0193','0194','0199',
   '0200','0201','0202','0203','0204','0206','0207','0208','0209',
   '0210','0211','0212','0213','0214','0219',
   '1000','1001','1002')
),


-- Lists unique claim_ds with valid ms_drg:
valid_ms_drg as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where ms_drg_code in (select ms_drg_code from {{ ref('terminology__ms_drg')}})
),


-- **************************************************
-- Here we define all encounter types:
-- **************************************************



-- ****  'acute inpatient - institutional'  ****
-- Lists unique claim_ids that meet the logic
-- criteria for the
-- 'acute inpatient - institutional' encounter type:
acute_inpatient_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where left(bill_type_code,1) in ('1','4','8')
      and 
      ( claim_id in (select * from room_and_board) )
      and
      ( claim_id in (select * from valid_ms_drg) )
),

-- ****  'acute inpatient - professional'  ****
-- Lists unique claim_ids that meet the logic
-- criteria for the
-- 'acute inpatient - professional' encounter type:
acute_inpatient_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '21'
),


-- ****  'inpatient rehabilitation - institutional'  ****
-- Lists unique claim_ids that meet the logic
-- criteria for the
-- 'inpatient rehabilitation - institutional' encounter type:
inpatient_rehabilitation_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code in ('0024','0118','0128','0138','0148','0158')
),


-- ****  'inpatient rehabilitation - professional'  ****
-- Lists unique claim_ids that meet the logic
-- criteria for the
-- 'inpatient rehabilitation - professional' encounter type:
inpatient_rehabilitation_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '61'
),


inpatient_psychiatric_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code in
  ('0114','0124','0134','0144',
   '0154','0204','0513','1001')
),


inpatient_psychiatric_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code in ('51','52','56')
),


inpatient_substance_abuse_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code = '1002'
),


inpatient_substance_abuse_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code in ('55','57','58')
),


skilled_nursing_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where left(bill_type_code,1) = '2'
),


skilled_nursing_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code in ('31','32')
),


ambulatory_surgery_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where substring(bill_type_code, 1, 2) = '83'
),


ambulatory_surgery_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '24'
),


dialysis_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where substring(bill_type_code, 1, 2) = '72'
),


dialysis_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '65'
),


emergency_department_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code in ('0450','0451','0452','0459','0981')
),


emergency_department_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '23'
),


urgent_care_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where revenue_center_code in ('0456','0516','0526')
),


urgent_care_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '20'
),

home_health_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where left(bill_type_code,1) = '3'
),


home_health_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '12'
),


hospice_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where substring(bill_type_code, 1, 2) in ('81','82')
),


hospice_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '34'
),


outpatient_rehabilitation_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where substring(bill_type_code, 1, 2) in ('74','75')
),


outpatient_rehabilitation_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '62'
),


outpatient_mental_health_institutional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where substring(bill_type_code, 1, 2) = '76'
),


outpatient_mental_health_professional as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code = '53'
),


office_visit as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code in ('11','17','49','50','71','72')
),


telehealth as (
select distinct claim_id
from {{ ref('claims_preprocessing__medical_claim') }}
where place_of_service_code in ('02','10')
),

encounter_types_temp as (
select
  claim_id,
  'acute inpatient' as encounter_type,
  'acute inpatient - institutional' as encounter_type_detail
from acute_inpatient_institutional

union all

select
  claim_id,
  'acute inpatient' as encounter_type,
  'acute inpatient - professional' as encounter_type_detail
from acute_inpatient_professional

union all

select
  claim_id,
  'inpatient rehabilitation' as encounter_type,
  'inpatient rehabilitation - institutional' as encounter_type_detail
from inpatient_rehabilitation_institutional

union all

select
  claim_id,
  'inpatient rehabilitation' as encounter_type,
  'inpatient rehabilitation - professional' as encounter_type_detail
from inpatient_rehabilitation_professional

union all

select
  claim_id,
  'inpatient psychiatric' as encounter_type,
  'inpatient psychiatric - institutional' as encounter_type_detail
from inpatient_psychiatric_institutional

union all

select
  claim_id,
  'inpatient psychiatric' as encounter_type,
  'inpatient psychiatric - professional' as encounter_type_detail
from inpatient_psychiatric_professional

union all

select
  claim_id,
  'inpatient substance abuse' as encounter_type,
  'inpatient substance abuse - institutional' as encounter_type_detail
from inpatient_substance_abuse_institutional

union all

select
  claim_id,
  'inpatient substance abuse' as encounter_type,
  'inpatient substance abuse - professional' as encounter_type_detail
from inpatient_substance_abuse_professional

union all

select
  claim_id,
  'skilled nursing' as encounter_type,
  'skilled nursing - institutional' as encounter_type_detail
from skilled_nursing_institutional

union all

select
  claim_id,
  'skilled nursing' as encounter_type,
  'skilled nursing - professional' as encounter_type_detail
from skilled_nursing_professional

union all

select
  claim_id,
  'ambulatory surgery' as encounter_type,
  'ambulatory surgery - institutional' as encounter_type_detail
from ambulatory_surgery_institutional

union all

select
  claim_id,
  'ambulatory surgery' as encounter_type,
  'ambulatory surgery - professional' as encounter_type_detail
from ambulatory_surgery_professional

union all

select
  claim_id,
  'dialysis' as encounter_type,
  'dialysis - institutional' as encounter_type_detail
from dialysis_institutional

union all

select
  claim_id,
  'dialysis' as encounter_type,
  'dialysis - professional' as encounter_type_detail
from dialysis_professional

union all

select
  claim_id,
  'emergency department' as encounter_type,
  'emergency department - institutional' as encounter_type_detail
from emergency_department_institutional

union all

select
  claim_id,
  'emergency department' as encounter_type,
  'emergency department - professional' as encounter_type_detail
from emergency_department_professional

union all

select
  claim_id,
  'urgent care' as encounter_type,
  'urgent care - institutional' as encounter_type_detail
from urgent_care_institutional

union all

select
  claim_id,
  'urgent care' as encounter_type,
  'urgent care - professional' as encounter_type_detail
from urgent_care_professional

union all

select
  claim_id,
  'home health' as encounter_type,
  'home health - institutional' as encounter_type_detail
from home_health_institutional

union all

select
  claim_id,
  'home health' as encounter_type,
  'home health - professional' as encounter_type_detail
from home_health_professional

union all

select
  claim_id,
  'hospice' as encounter_type,
  'hospice - institutional' as encounter_type_detail
from hospice_institutional

union all

select
  claim_id,
  'hospice' as encounter_type,
  'hospice - professional' as encounter_type_detail
from hospice_professional

union all

select
  claim_id,
  'outpatient rehabilitation' as encounter_type,
  'outpatient rehabilitation - institutional' as encounter_type_detail
from outpatient_rehabilitation_institutional

union all

select
  claim_id,
  'outpatient rehabilitation' as encounter_type,
  'outpatient rehabilitation - professional' as encounter_type_detail
from outpatient_rehabilitation_professional

union all

select
  claim_id,
  'outpatient mental health' as encounter_type,
  'outpatient mental health - institutional' as encounter_type_detail
from outpatient_mental_health_institutional

union all

select
  claim_id,
  'outpatient mental health' as encounter_type,
  'outpatient mental health - professional' as encounter_type_detail
from outpatient_mental_health_professional

union all

select
  claim_id,
  'office visit' as encounter_type,
  'office visit' as encounter_type_detail
from office_visit

union all

select
  claim_id,
  'telehealth' as encounter_type,
  'telehealth' as encounter_type_detail
from telehealth

)

select *
from encounter_types_temp