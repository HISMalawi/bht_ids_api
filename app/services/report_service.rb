class ReportService

	def initialize(start_date:, end_date:, district_id:, site_id:)
		@start_date  = start_date
		@end_date    = end_date
		@district    = Location.find(district_id)
		@site        = Site.find(site_id)
	end

	def cbs_art_initiated(rds_db)
		hts_client_ids = hts_clients
		hts_client_ids = [0] if hts_client_ids.blank?
		data = ActiveRecord::Base.connection.select_all <<EOF
		SELECT distinct e.person_id, 
		TIMESTAMPDIFF(year,DATE(p.birthdate),DATE('#{@end_date}')) age, p.gender,
        hsi.date_enrolled 
		FROM encounters e
        JOIN people	p
        ON e.person_id = p.person_id
        JOIN hiv_staging_infos hsi 
        ON e.person_id = hsi.person_id
		WHERE e.program_id = 1 AND e.person_id IN (#{hts_client_ids.join(',')})
        AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}';
EOF

		art_vs_hts = {}

		art_vs_hts['art_init'] = data
		art_vs_hts['hts_postive'] = hts_postive(rds_db)

		return art_vs_hts

	end

	def cbs_case_listing
		case_hash = {}

		data = ActiveRecord::Base.connection.select_all <<EOF
		SELECT DISTINCT dii.identifier surveillance_id, pht.person_id,p.gender,p.birthdate,hsi.date_enrolled,hsi.start_date,hsi.who_stage, hsi.age_at_initiation,
		hsi.hiv_test_date, hsi.hiv_test_facility
		FROM person_has_types pht
        INNER JOIN hiv_staging_infos hsi ON pht.person_id = hsi.person_id
		INNER JOIN people p ON pht.person_id = p.person_id
		INNER JOIN de_identified_identifiers dii ON pht.person_id = dii.person_id
		WHERE person_type_id = 1
        AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}'
        ;  

EOF
		data.each do |r|
			viral_result = viral_load r["person_id"]
			case_hash[r["person_id"]] = {
					surveillance:  r["surveillance_id"],
					gender:        (r["gender"] == "0" ? 'M' : 'F'),
					birthdate:     r["birthdate"],
					date_enrolled: r["date_enrolled"],
					hiv_test_date: r["hiv_test_date"],
					hiv_test_facility: r["hiv_test_facility"],
					initiation_date:    r["start_date"],
					who_stage:     (definition_name r["who_stage"]),
					age_at_initiation: r["age_at_initiation"],
					latest_vl_result: viral_result.blank? ? 'N/A' : viral_result.first.result,
					latest_vl_date: viral_result.blank? ? 'N/A' : viral_result.first.test_result_date,
					latest_vl_facility: viral_result.blank? ? 'N/A' : viral_result.first.results_test_facility,
					current_regimen: (art_regimen r['person_id'])
			}
		end
		return case_hash
	end

	def cbs_client_case(person_id)
		case_hash = {}

		data = ActiveRecord::Base.connection.select_all <<EOF
		SELECT DISTINCT  pht.person_id,p.gender,p.birthdate,hsi.date_enrolled,hsi.start_date,hsi.who_stage, hsi.age_at_initiation,
		hsi.hiv_test_date, hsi.hiv_test_facility
		FROM person_has_types pht
        INNER JOIN hiv_staging_infos hsi ON pht.person_id = hsi.person_id
		INNER JOIN people p ON pht.person_id = p.person_id
		INNER JOIN de_identified_identifiers dii ON pht.person_id = dii.person_id
		WHERE person_type_id = 1
		AND pht.person_id = #{person_id}
        AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}'
        ;  

EOF
		data.each do |r|
			raise r.inspect
			viral_result = viral_load r["person_id"]
			case_hash[r["person_id"]] = {
					#surveillance:  r["surveillance_id"],
					gender:        (r["gender"] == "0" ? 'M' : 'F'),
					birthdate:     r["birthdate"],
					date_enrolled: r["date_enrolled"],
					hiv_test_date: r["hiv_test_date"],
					hiv_test_facility: r["hiv_test_facility"],
					initiation_date:    r["start_date"],
					who_stage:     (definition_name r["who_stage"]),
					age_at_initiation: r["age_at_initiation"],
					latest_vl_result: viral_result.blank? ? 'N/A' : viral_result.first.result,
					latest_vl_date: viral_result.blank? ? 'N/A' : viral_result.first.test_result_date,
					latest_vl_facility: viral_result.blank? ? 'N/A' : viral_result.first.results_test_facility,
					current_regimen: (art_regimen r['person_id'])
			}
		end
		return case_hash
	end

	

	private

	def definition_name(def_id)
		MasterDefinition.find_by(def_id).definition rescue def_id
	end

	

	def viral_load(person_id)
		latest_viral_date = LabTestResult.find_by_sql("SELECT max(test_result_date) AS trd FROM lab_test_results ltr
			                               JOIN lab_orders lo ON ltr.lab_order_id = lo.lab_order_id
			                               JOIN encounters en ON lo.encounter_id = en.encounter_id
			                               WHERE en.person_id = #{person_id}
			                               AND ltr.test_measure = 'Viral Load'")

		return if latest_viral_date.first.trd.blank?


		viral_results = LabTestResult.find_by_sql("SELECT ltr.result, ltr.test_result_date, ltr.results_test_facility FROM  lab_test_results ltr
			                               JOIN lab_orders lo ON ltr.lab_order_id = lo.lab_order_id
			                               JOIN encounters en ON lo.encounter_id = en.encounter_id
			                               WHERE en.person_id = #{person_id}
			                               AND ltr.test_result_date = '#{latest_viral_date.first.trd.strftime("%Y-%m-%d")}'
			                               AND ltr.test_measure = 'Viral Load'")
		return viral_results
	end

	def hts_clients
		data = ActiveRecord::Base.connection.select_all <<EOF
        SELECT pht.person_id
		FROM person_has_types pht		
		INNER JOIN encounters en ON pht.person_id = en.person_id		
		AND en.program_id = 18;
EOF

		patient_ids = []
		data.each do |d|
			patient_ids << d["person_id"].to_i
		end
		return patient_ids
	end

	def art_regimen(person_id)
		current_regimen_date = MedicationDispensation.find_by_sql("SELECT max(md.app_date_created) date                                                  FROM medication_dispensations md
                                                            JOIN medication_prescriptions  mp
                                                            ON md.medication_prescription_id = mp.medication_prescription_id
                                                            JOIN medication_prescription_has_medication_regimen mphmr
                                                            ON mphmr.medication_prescription_encounter_id = mp.encounter_id
                                                            JOIN encounters e
                                                            ON mp.encounter_id = e.encounter_id
                                                            WHERE e.person_id = #{person_id}
                                                            AND e.program_id = 1
                                                            AND mp.drug_id in (SELECT drug_id from arv_drugs)")
		return 'Unknown' if current_regimen_date.first.date.blank?

		current_regimen_dispensed = MedicationRegimen.find_by_sql("SELECT mr.regimen regimen FROM medication_regimen mr
                                                            JOIN medication_prescription_has_medication_regimen mphmr
                                                            ON mr.medication_regimen_id = mphmr.medication_regimen_id
                                                            JOIN medication_prescriptions mp
                                                            ON mphmr.medication_prescription_encounter_id = mp.encounter_id
                                                            JOIN medication_dispensations md
                                                            ON mp.medication_prescription_id = md.medication_prescription_id
                                                            JOIN encounters en
                                                            ON mp.encounter_id = en.encounter_id
                                                            WHERE en.person_id = #{person_id}
                                                            AND e.program_id = 1
                                                            AND md.app_date_created = '#{current_regimen_date.first.date}';")

		return current_regimen_dispensed.first.regimen || "Unknown"
	end

	def hts_postive(rds_db)
		data = ActiveRecord::Base.connection.select_all <<~SQL
    SELECT distinct e.person_id, (year(now() - year(p.birthdate))) age, p.gender,
        hsi.date_enrolled 
        FROM encounters e
        JOIN people p
        ON e.person_id = p.person_id
        JOIN hiv_staging_infos hsi 
        ON e.person_id = hsi.person_id
        WHERE e.program_id = 18 AND e.person_id IN (select distinct person_id from #{rds_db}.obs where concept_id = 8497)
        AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}';
		SQL

		return data
	end
end


