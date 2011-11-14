class SplitPublicationDateInWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :publication_date_year, :integer
    add_column :works, :publication_date_month, :integer
    add_column :works, :publication_date_day, :integer
    IndexObserver.skip = true
    Work.all.each do |work|
      if work.publication_date.present?
        work.update_attribute(:publication_date_year, work.publication_date.year)
        work.update_attribute(:publication_date_month, work.publication_date.month)
        work.update_attribute(:publication_date_day, work.publication_date.day)
      else
        work.update_attribute(:publication_date_year, nil)
        work.update_attribute(:publication_date_month, nil)
        work.update_attribute(:publication_date_day, nil)
      end
    end
    remove_column :works, :publication_date
  end

  def self.down
    add_column :works, :publication_date, :date
    IndexObserver.skip = true
    Work.all.each do |work|
      if work.publication_date_year.present?
        work.update_attribute(:publication_date, Date.new(work.publication_date_year, work.publication_date_month || 1, work.publication_date_day || 1))
      else
        work.update_attribute(:publication_date, nil)
      end
    end
    remove_column :works, :publication_date_day
    remove_column :works, :publication_date_month
    remove_column :works, :publication_date_year
  end
end
