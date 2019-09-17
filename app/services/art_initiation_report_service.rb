# frozen_string_literal: true

class ArtInitiationReportService < ReportService
  def cbs_art_initiated(rds_db)
    hts_client_ids = hts_clients
	hts_client_ids = [0] if hts_client_ids.blank?
	
	site_name = Site.find_by_site_id(@site.to_i)['site_name']

	rds_site_id = ActiveRecord::Base.connection.select_one <<~SQL
	  SELECT location_id FROM #{rds_db}.location
	SQL

	hts_confimatory_positive = hts_postive(rds_db, site_id)
	

		hts_initated = ActiveRecord::Base.connection.select_all <<~SQL
		  SELECT hsi.person_id, hsi.age_at_initiation num, p.birthdate
		  FROM encounters e
	      JOIN people	p
	      ON e.person_id = p.person_id
	      JOIN hiv_staging_infos hsi 
	      ON e.person_id = hsi.person_id
	      JOIN medication_prescriptions mp 
	      ON e.encounter_id = mp.encounter_id
	      JOIN medication_prescription_has_medication_regimen mphr
	      ON mp.encounter_id = mphr.medication_prescription_encounter_id
		  WHERE e.program_id = 18
	      AND date_enrolled BETWEEN '#{@start_date}' AND '#{@end_date}'
	      AND mid(e.encounter_id,-5,5) = #{rds_site_id['location_id']};
        SQL

		art_vs_hts = {}
		art_vs_hts['tested_positive_and_art_initiated'] = 

		art_vs_hts['hts_postive'] = 

		return art_vs_hts
	end

	def hts_postive(rds_db, site_id)
		data = ActiveRecord::Base.connection.select_all <<~SQL
	      SELECT person_id, obs_datetime, p.gender, p.birthdate FROM
	      #{rds_db}.obs ob 
	      JOIN person p on ob.person_id = p.person_id
	      WHERE value_coded = 8497
	      AND obs_datetime BETWEEN '#{@start_date}' AND '#{@end_date}'
	      AND mid(person_id,-5,5) = #{site_id.to_i};
		SQL
     return data
	end

	def hts_clients
		data = ActiveRecord::Base.connection.select_all <<~SQL
          SELECT pht.person_id
		  FROM person_has_types pht		
		  INNER JOIN encounters en ON pht.person_id = en.person_id		
		  AND en.program_id = 18;
    	SQL

		patient_ids = []
		data.each do |d|
			patient_ids << d["person_id"].to_i
		end
		return patient_ids
	end

  def group_by_age_and_sex(people)
    grp_by_age = {
    	'<1' 	 => [],
    	'1-9' 	 => [],
    	'10-14M' => [],
    	'10-14F' => [],
        '15-19F' => [],
        '15-19M' => [],
        '20-24M' => [],
        '20-24F' => [],
        '25-49F' => [],
        '25-49M' => [],
        '50+M'   => [],
        '50+F'   => []
    }

    people.each do |person|
       age = Time.now.year - person['birthdate'].year
       case age
       	when < 1
       	  group_data['<1'] << person['person_id']
       	when 1..9
       	  group_data['1-9'] << person['person_id']
       	when 10..14
       		if person['gender'] == 'M'
       		  group_data['10-14M'] << person['person_id']
       		elsif person['gender'] == 'F'
       		  group_data['10-14F'] << person['person_id']
       		end
       	when 15..19
       		if person['gender'] == 'M'
       		  group_data['15-19M'] << person['person_id']
       		elsif person['gender'] == 'F'
       		  group_data['15-19F'] << person['person_id']
       		end
        when 20..24
            if person['gender'] == 'M'
       		  group_data['20-24M'] << person['person_id']
       		elsif person['gender'] == 'F'
       		  group_data['20-24F'] << person['person_id']
       		end
       	when 25..49
       		if person['gender'] == 'M'
       		  group_data['25-49M'] << person['person_id']
       		elsif person['gender'] == 'F'
       		  group_data['25-49F'] << person['person_id']
       		end
       	when >= 50
       		if person['gender'] == 'M'
       		  group_data['50+M'] << person['person_id']
       		elsif person['gender'] == 'F'
       		  group_data['50+F'] << person['person_id']
       		end	
       	end
    end
  end

end