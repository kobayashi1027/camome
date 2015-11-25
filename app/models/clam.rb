class Clam < ActiveRecord::Base
  belongs_to :mission
  has_one :resource
  serialize :options
  has_many :clam_events
  has_many :events, through: :clam_events
  # for reuse info
  has_one :parent_relation, foreign_key: 'child_id', class_name: 'ReuseRelationship'
  has_many :child_relations, foreign_key: 'parent_id', class_name: 'ReuseRelationship'
  has_one :reuse_parent, through: :parent_relation, source: :parent
  has_many :reuse_children, through: :child_relations, source: :child

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.options || {})[:#{method_name}]
        end
        def #{method_name}=(value)
          self.options ||= {}
          self.options[:#{method_name}] = value
        end
      "
    end
  end

  def self.search(search)
    if search
      Clam.where(['options LIKE ? or summary LIKE ?', "%#{search}%", "%#{search}%"])
    else
      Clam.all
    end
  end

  # return clams that has been reused, or has been created by reusing
  def self.narrow_by_reuseinfo
    r_clams = Clam.joins(:parent_relation).uniq + Clam.joins(:child_relations).uniq
    Clam.where(id: r_clams.map{|r_clam| r_clam.id})
  end

  serialized_attr_accessor :description, :originator, :recipients
end
