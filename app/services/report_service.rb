class ReportService

	def initialize(start_date:, end_date:, district_id:, site_id:)
       @start_date  = start_date
       @end_date    = end_date
       @district    = Location.find(district_id)
       @site        = Site.find(site_id)
	end

# 	def cbs_art_initiated
# 		data = ActiveRecord::Base.connection.select_all <<EOF
# 		SELECT * 
# EOF		
		
# 	end

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
            latest_vl_facility: viral_result.blank? ? 'N/A' : viral_result.first.results_test_facility
        		
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
      

		viral_results = LabTestResult.find_by_sql("SELECT ltr. result, ltr.test_result_date, ltr.results_test_facility FROM  lab_test_results ltr 
			                               JOIN lab_orders lo ON ltr.lab_order_id = lo.lab_order_id
			                               JOIN encounters en ON lo.encounter_id = en.encounter_id
			                               WHERE en.person_id = #{person_id}
			                               AND ltr.test_result_date = '#{latest_viral_date.first.trd.strftime("%Y-%m-%d")}'
			                               AND ltr.test_measure = 'Viral Load'")
        return viral_results

	end

	
end
  
      
    