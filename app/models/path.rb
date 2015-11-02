class Path < ActiveRecord::Base

  include Enumerable

  belongs_to :datum, polymorphic: true
  belongs_to :brought_in_by, foreign_key: :brought_in_by_id, class_name: "User"
  belongs_to :brought_out_by, foreign_key: :brought_out_by_id, class_name: "User"

  scope :contents_of, -> (box_id) { where("? = ANY(ids)", box_id) }
  scope :current, -> { where(brought_out_at: nil) }

  def self.cont_at(date)
    search = search(brought_out_at_gteq: date, brought_in_at_lteq_end_of_day: date)
    records = search.result
    records = records.current if search.conditions.empty?
    records = records.group(:datum_id, :datum_type, :ids)
    records = records.select(:datum_id, :datum_type, :ids, arel_table[:brought_in_at].maximum.as("brought_in_at"), arel_table[:brought_out_at].maximum.as("brought_out_at"))
    records
  end

  def self.diff(box, src_date, dst_date)
    src = contents_of(box).cont_at(src_date).as("src")
    dst = contents_of(box).cont_at(dst_date).as("dst")
    join = arel_table.project("CASE WHEN src.datum_id IS NULL THEN '+' ELSE '-' END AS sign, COALESCE(src.datum_id, dst.datum_id) AS datum_id, COALESCE(src.datum_type, dst.datum_type) AS datum_type, COALESCE(src.ids, dst.ids) AS ids, COALESCE(src.brought_in_at, dst.brought_in_at) AS brought_in_at, COALESCE(src.brought_out_at, dst.brought_out_at) AS brought_out_at")
    join = join.from(src).join(dst, Arel::Nodes::FullOuterJoin).on(src[:datum_id].eq(dst[:datum_id]).and(src[:datum_type].eq(dst[:datum_type])).and(src[:ids].eq(dst[:ids])))
    join = join.where(src[:datum_id].eq(nil).or(dst[:datum_id].eq(nil)))
    select("*").from(join.as("paths"))
  end

  def each
    if ids.present?
      boxes = Box.where(id: ids).includes(:record_property).index_by(&:id)
      ids.each { |id| yield boxes[id] }
    end
    yield datum
  end

  private

  ransacker :path do
    Arel.sql("(SELECT string_agg(name, '/') FROM unnest(ids) AS i INNER JOIN boxes ON id = i) || '/' || (CASE datum_type WHEN 'Stone' THEN (SELECT name FROM stones WHERE id = datum_id) WHEN 'Box' THEN (SELECT name FROM boxes WHERE id = datum_id) END)")
  end

  ransacker :brought_out_at do |parent|
    Arel.sql("coalesce(brought_out_at, '9999-12-31 23:59:59')")
  end

end