class ReportService

	def initialize(start_date:, end_date:, district_id:, site_id:)
       @start_date  = start_date
       @end_date    = end_date
       @district    = Location.find(district_id)
       @site        = Site.find(site_id)
	end

	def cbs_case_listing
		case_hash = {}		

        data = ActiveRecord::Base.connection.select_all <<EOF
        SELECT pht.person_id,p.gender,p.birthdate,hsi.date_enrolled,hsi.start_date,hsi.who_stage, hsi.age_at_initiation FROM person_has_types pht
        INNER JOIN hiv_staging_infos hsi ON pht.person_id = hsi.person_id
        INNER JOIN people p ON pht.person_id = p.person_id
        WHERE person_type_id = 1
        AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}'
        ;  
        
EOF
     
        data.each do |r|
        	case_hash[r["person_id"]] = {
        		#surveillance:  (surveillance_id r["person_id"]),
        		gender:        (r["gender"] == "0" ? 'M' : 'F'),
        		birthdate:     r["birthdate"],
        		date_enrolled: r["date_enrolled"],
        		initiation_date:    r["start_date"],
        		who_stage:     (definition_name r["who_stage"]),
        		age_at_initiation: r["age_at_initiation"]
        	}
        end
        return case_hash
	end	


	private

	def definition_name(def_id)
		 MasterDefinition.find(def_id).definition rescue def_id
	end

	def surveillance_id(person_id)
		DeIdentifiedIdentifier.find(person_id).identifier
	end

end
  
      
    