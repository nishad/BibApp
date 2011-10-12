# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'config/personalize.rb'

  def ajax_pen_name_checkbox_toggle(name_string, person, selected, reload = false)
    if selected
      pen_name = PenName.find_by_person_id_and_name_string_id(person.id, name_string.id)
      js = remote_function(:url => pen_name_url(pen_name, :reload => reload, :person_id => person.id,
                                                :name_string_id => name_string.id),
                           :method => :delete)
    else
      js = remote_function(:url => pen_names_url(:person_id => person.id, :reload => reload,
                                                 :name_string_id => name_string.id),
                           :method => :post)
    end
    check_box_tag("name_string_#{name_string.id}_toggle", 1, selected, {:onclick => js})
  end

  #Generate a "Find It!" OpenURL link,
  # based on Work information as received from Solr
  def link_to_findit(work)

    #Get our OpenURL information
    link_text, base_url, suffix = find_openurl_info

    suffix =coin(work)

    # Prepare link
    link_to link_text, "#{base_url}?#{suffix}"
  end

  def coin(work)
    # @TODO - improve - probably have subklass.to_coin methods for each.
    # Genre differences: journal/article = atitle ; book/proceeding = title

    coin = "ctx_ver=Z39.88-2004" # OpenURL 1.0

    # We want AR objects!
    if work.class == Hash
      begin
        work = Work.find(work["pk_i"])
      rescue
        return coin
      end
    end


    if work.open_url_kevs.present?
      work.open_url_kevs.values.each do |value| # Work Subklass Kevs
        coin += value
      end
    end

    work.authors.each do |au| # Authors
      coin += "&rft.au=#{au[:name]}"
    end

    coin
  end

  #Encodes UTF-8 data such that it is valid in XML
  def encode_for_xml(data)
    code = HTMLEntities.new
    code.encode(data, :basic)
  end

  #Finds the Error message for a *specific field* in a Form
  # This is useful to display the error messages next to the
  # appropriate field in a form.
  # This displays a <div> with the error message right after the field
  # Borrowed from: http://www.sciwerks.com/blog/category/ruby-on-rails/page/2/
  def error_for(object, method = nil, options={})
    if method
      err = instance_variable_get("@#{object}").errors[method].to_sentence rescue instance_variable_get("@#{object}").errors[method]
    else
      err = @errors["#{object}"] rescue nil
    end
    if err.present?
      options.merge!(:class=>'fieldWithErrors', :id=>"#{[object, method].compact.join('_')}-error", :style=> (err ? "#{options[:style]}" : "#{options[:style]};display: none;"))
      content_tag("p", err || "", options)
    end
  end

  #create a hash for Haml that gives id => current if the controller matches the argument
  def give_current_id_if_equal(name1, name2)
    name1 == name2 ? {:id => 'current'} : {}
  end

  def give_current_class_if_equal(name1, name2)
    name1 == name2 ? {:class => 'current'} : {}
  end

  private

  #Find information necessary to build our OpenURL query
  #  In particular:
  #    OpenURL link text, base url, and query suffixes
  def find_openurl_info
    # Set the canonical resolver variables (from personalize.rb)
    link_text = $WORK_LINK_TEXT
    base_url = $WORK_BASE_URL
    suffix = $WORK_SUFFIX
    # #If we've already found this info for
    # # the current session, return it immediately
    # if session[:openurl_info]
    #   link_text = session[:openurl_link_text] if session[:openurl_link_text]
    #   base_url = session[:openurl_base_url] if session[:openurl_base_url]
    # else
    #   # Obtain the client IP Address
    #   ip = request.env["HTTP_X_FORWARDED_FOR"]
    #   logger.debug("Client IP: #{ip}")

    #   # Test UW-Madison
    #   #ip = "128.104.198.84"

    #   # Test UIUC
    #   #ip = "128.174.36.29"

    #   # Test Iowa
    #   #ip = "128.255.56.180"

    #   # Initialize ResolverRegistry
    #   client = ResolverRegistry::Client.new

    #   # @TODO: Can this be improved?
    #   #
    #   # Steps for ResolverRegistry results
    #   # 1) Look up *all* the resolvers held for a university
    #   # * Some universities have more than one resolver (Iowa has 4!)
    #   # * Some resolvers look specific to ILL
    #   # * Some resolvers are for "Ask a Librarian" type services
    #   #
    #   # 2) If there are no results use the personalize.rb defaults
    #   #
    #   # 3) Loop through results
    #   #
    #   # 4) Choose best resolver option
    #   # * Best option (at least at UW, UIUC, Iowa) seems to be the resolver without specific metadata_formats
    #   begin
    #     institution = client.lookup_all(ip)

    #     # Test the ResolverRegistry results...
    #     # If the ResolverRegistry returns nil
    #     if institution.nil?
    #       # Use the default variables
    #     # Else loop and choose the "best option"
    #     else
    #       institution.each do |i|
    #         if i.resolver.metadata_formats.empty?
    #           base_url = i.resolver.base_url
    #           link_text = i.resolver.link_text
    #           session[:openurl_link_text] = link_text
    #           session[:openurl_base_url] = base_url
    #         end
    #       end
    #     end
    #   rescue
    #     #If errors, do nothing - just use the defaults from personalize.rb
    #   end #end begin

    #   # whether we got results or not, flag that we already tried using OpenURL ResolverRegistry
    #   session[:openurl_info] = true
    # end #end if session[:openurl_info]
    return link_text, base_url, suffix
  end

  #mark stylesheets for inclusion in layout via yield :stylesheets
  #prevent including the same one more than once - note we could do
  #this more efficiently if need be
  def include_stylesheets(*paths)
    paths.each do |path|
      new_link = stylesheet_link_tag(path)
      unless content_for(:stylesheets).include?(new_link)
        content_for(:stylesheets, new_link + "\n")
      end
    end
  end

  alias include_stylesheet include_stylesheets

  def include_javascripts(*paths)
    paths.each do |path|
      new_link = javascript_include_tag(path)
      unless content_for(:javascripts).include?(new_link)
        content_for(:javascripts, new_link + "\n")
      end
    end
  end

  alias include_javascript include_javascripts

  def include_data_tables
    include_javascript('datatables/jquery.dataTables')
    include_stylesheet('common/datatables')
  end

  #make a hidden div with the given id containing the given data, converted to json and html
  #encoded. We have a corresponding javascript function to take this back apart.
  def js_data_div(id, data)
    content_tag(:div, h(data.to_json), :id => id, :class => 'hidden')
  end

  #Take the xml builder and a block.
  #Generate boilerplate then yield to the block
  def rdf_document_on(xml_builder)
    xml_builder.instruct!
    xml_builder.rdf(:RDF, {'xmlns:rdf'=>"http://www.w3.org/1999/02/22-rdf-syntax-ns#", 'xmlns:bibo'=>"http://purl.org/ontology/bibo/", 'xmlns:foaf'=>"http://xmlns.com/foaf/0.1/", 'xmlns:owl'=>"http://www.w3.org/2002/07/owl#", 'xmlns:xsd'=>"http://www.w3.org/2001/XMLSchema#", 'xmlns:core'=>"http://vivoweb.org/ontology/core#", 'xmlns:vitro'=>"http://vitro.mannlib.cornell.edu/ns/vitro/0.7#", 'xmlns:rdfs'=>"http://www.w3.org/2000/01/rdf-schema#"}) do
      yield
    end
  end

  #Take xml builder and a block
  #Generate boilerplate and yield to block
  def rss_document_on(xml_builder)
    xml_builder.instruct!
    xml_builder.rss "version" => 2.0, "xmlns:dc" => "http://purl.org/dc/elements/1.1" do
      yield
    end
  end

  def current_user_role?(role, object)
    logged_in? and current_user.has_role?(role, object)
  end

  def current_user_any_role?(role, object)
    logged_in? and current_user.has_any_role?(role, object)
  end

  def authorizable_type(authorizable)
    authorizable.is_a?(Class) ? authorizable.to_s : authorizable.class.to_s
  end

  def authorizable_id(authorizable)
    authorizable.is_a?(Class) ? nil : authorizable.id
  end

  #return 'selected' if x == y, nil otherwise. Useful for select option generation
  def selected_if_equal(x, y)
    x == y ? 'selected' : nil
  end

end
