class BookWhole < Work
  validates_presence_of :title_primary

  class << self
    def roles
      ['Author', 'Editor', 'Translator', 'Illustrator']
    end
  end
  
  def open_url_kevs
    open_url_kevs = Hash.new
    open_url_kevs[:format]      = "&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook"
    open_url_kevs[:genre]       = "&rft.genre=book"
    open_url_kevs[:title]       = "&rft.btitle=#{CGI.escape(self.title_primary)}"
    open_url_kevs[:publisher]   = "&rft.pub=#{self.publisher.authority.name}"
    open_url_kevs[:isbn]        = "&rft.isbn=#{self.publication.isbns.first[:name]}" if !self.publication.isbns.empty?
    open_url_kevs[:date]        = "&rft.date=#{self.publication_date}"
    
    return open_url_kevs
  end
end