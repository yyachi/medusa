class RecordsController < ApplicationController
  respond_to :html, :json, :xml
  before_action :find_resource, except: [:index]

  # TODO: Ransackでの検索は無理か？自作も視野に...
  def index
    @records = RecordProperty.where.not(datum_type: "Chemistry").page(params[:page]).per(params[:per_page])
    respond_with @records # TODO: jsonおよびxml表現ではどのような形式で欲しいのか？
  end

  def show
    respond_with @record do |format|
      format.html { redirect_to @record }
    end
  end

  def property
    respond_with @record.record_property
  end

  private

  def find_resource
    @record = RecordProperty.find_by!(global_id: params[:id]).datum
    authorize!(params[:action], @record)
  end
end
