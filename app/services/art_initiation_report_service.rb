# frozen_string_literal: true

class ArtInitiationReportService < ReportService
  def cbs_art_initiated
    hts_postive_ids = hts_postive
	hts_postive_ids = [0] if hts_postive_ids.blank?

	hts_positive_initiated = positive_initiated(hts_postive_ids.uniq)
	
	hts_positive_not_initiated = hts_postive_ids - hts_positive_initiated
    
    initiated = group_by_age_and_sex(hts_positive_initiated)
	non_initiated = group_by_age_and_sex(hts_positive_not_initiated)

	art_vs_hts = [
		{ 'age_range' => '<1', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '1-9', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '10-14M', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '10-14F', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '15-19M', 'w_init' => 0, 'wtout_init' => 0},
		{ 'age_range' => '15-19F', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '20-24M', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '25-49F', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '50+M', 'w_init' => 0, 'wtout_init' => 0 },
		{ 'age_range' => '50+F', 'w_init' => 0, 'wtout_init' => 0 }
	]
   
   art_vs_hts.each do |record|
   	 initiated.each do |key, value|
   	     record['w_init'] = value.to_i if record['age_range'] == key
   	 end 
   end

   art_vs_hts.each do |record|
   	 non_initiated.each do |key, value|
   	     record['wtout_init'] = value.to_i if record['age_range'] == key
   	 end 
   end

   return art_vs_hts
  end

  def hts_postive
    # Note need to change value coded to the correct one for positives after
    # fixing meta-data
    site_code = Site.find(@site.to_i)['site_code']

    data = Encounter.joins(
	        :hts_results_givens
			).where("
			program_id = 18  
			AND hts_results_givens.value_coded = 10249
			AND mid(htsrg_id,-5,5) = #{site_code}").select('encounters.person_id')
      ids = []

      data.each { |id| ids << id['person_id'] }         

     return ids.uniq
	end

	def positive_initiated(person_ids)
	 initiated = []
		 person_ids.each do |person_id|
		   duplicates = identify_potential_dupilcates(person_id)['duplicates'].join(',')

		   has_dispensation = ActiveRecord::Base.connection.select_all <<~SQL
		     SELECT person_id
			 FROM encounters en
		     JOIN medication_prescriptions mp 
		     ON en.encounter_id = mp.encounter_id
		     JOIN medication_dispensations md 
		     ON mp.medication_prescription_id = md.medication_prescription_id
		     WHERE person_id IN (#{duplicates}) limit 1;
		   SQL
	       initiated << person_id unless has_dispensation.blank?
	     end
       return initiated
	end

  def group_by_age_and_sex(people)
      people = [0] if people.empty?
	  group_age_and_gender = ActiveRecord::Base.connection.select_all <<~SQL	
	    SELECT
		 CASE 
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 0 AND 0.9 THEN '<1'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 1 AND 9 THEN '1-9'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 10 AND 14 AND gender = 1 THEN '10-14M'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 10 AND 14 AND gender = 0 THEN '10-14F'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 15 AND 19 AND gender = 1 THEN '15-19M'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 15 AND 19 AND gender = 0 THEN '15-19F'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 20 AND 24 AND gender = 1 THEN '20-24M'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 20 AND 24 AND gender = 0 THEN '20-24F'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 25 AND 49 AND gender = 1 THEN '25-49M'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) between 25 AND 49 AND gender = 0 THEN '25-49F'	
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) >= 50 AND gender = 1 THEN '50+M'
		    WHEN ROUND(DATEDIFF(CURRENT_DATE, birthdate)/365.25,1) >= 50 AND gender = 0 THEN '50+F'
		    else 'without dob or gender'
		 END as `RANGE`,
		 count(*) as count
		 FROM people
		 WHERE person_id IN (#{people.join(',')})
		 GROUP BY `RANGE`;
	  SQL
      grouped = {}
	  group_age_and_gender.each do |row|
	  	grouped["#{row['RANGE']}"] = row['count']
      end

    return grouped
  end
end