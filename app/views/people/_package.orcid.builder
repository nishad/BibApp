xml.tag!("message-version", "1.2")
xml.tag!("orcid-profile") do
	xml.tag!("orcid-bio") do
	  xml.tag!("personal-details") do
	  	xml.tag!("given-names", @person.first_name)
		  xml.tag!("family-name", @person.last_name)
#		  xml.tag!("other-names", "visibility"=>"public") do
# 		    pen_names = @person.pen_names.map do |pen_name|
#		      NameString.find(pen_name.name_string_id).name
#		    end
#		    pen_names.uniq.each do |ns|
# 		        xml.tag!("other-name", ns)
#		    end
#		  end
	  end
	  xml.tag!("contact-details") do
	    xml.email({"primary" => "true"}, @person.email)
	  end
### Example for adding keywords
# 	  xml.tag!("keywords") do
# 	    @person.works.map{|w| w.keywords.map{|k| k.name}}.flatten.uniq.each do |keyword|
# 	      xml.tag!("keyword", keyword)
# 	    end
# 	  end
###
		xml.tag!("external-identifiers", "visibility"=>"public") do
			xml.tag!("external-identifier") do
				xml.tag!("external-id-common-name", "#{t('personalize.university_full_name')} (#{t('personalize.university_short_name')}) #{t('personalize.application_name')}")
				xml.tag!("external-id-reference", @person.id)
				xml.tag!("external-id-url", person_url(@person))
			end
		end
	end
	xml.tag!("orcid-activities") do
    xml.affiliations do
      xml.affiliation do
        xml.type("employment")
        xml.tag!("department-name", @person.groups.first.name)
        xml.organization do
          xml.name(t('personalize.university_full_name'))
          xml.address do
            xml.city(t('personalize.university_city'))
            xml.region(t('personalize.university_region'))
            xml.country(t('personalize.university_country'))
          end
          xml.tag!("disambiguated-organization") do
            xml.tag!("disambiguated-organization-identifier", "#{t('personalize.university_unique_id')}")
            xml.tag!("disambiguation-source",  "#{t('personalize.university_unique_id_authority')}")
          end
        end
      end
    end
	  # @TODO: Citation exporters are very slow.
    export = WorkExport.new
    export.formatter = 'text'
		xml.tag!("orcid-works") do
			person.works.each do |w|
				xml << render(:partial => "shared/package", :locals => {:work => w, :export => export}) 
			end
		end
	end
end
