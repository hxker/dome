class Admin::ScoreAttributesController < AdminController
  before_action :set_score_attribute, only: [:show, :edit, :update, :destroy]

  # GET /admin/score_attributes
  # GET /admin/score_attributes.json
  def index
    if params[:field].present? && params[:keyword].present?
      @score_attributes = ScoreAttribute.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @score_attributes = ScoreAttribute.all.page(params[:page]).per(params[:per])
    end

  end

  # GET /admin/score_attributes/1
  # GET /admin/score_attributes/1.json
  def show
  end

  # GET /admin/score_attributes/new
  def new
    @score_attribute = ScoreAttribute.new
  end

  # GET /admin/score_attributes/1/edit
  def edit
  end

  # POST /admin/score_attributes
  # POST /admin/score_attributes.json
  def create
    @score_attribute = ScoreAttribute.new(score_attribute_params)

    respond_to do |format|
      if @score_attribute.save
        format.html { redirect_to [:admin, @score_attribute], notice: '成绩属性创建成功.' }
        format.json { render action: 'show', status: :created, location: @score_attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @score_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/score_attributes/1
  # PATCH/PUT /admin/score_attributes/1.json
  def update
    respond_to do |format|
      if @score_attribute.update(score_attribute_params)
        format.html { redirect_to [:admin, @score_attribute], notice: '成绩属性更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @score_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/score_attributes/1
  # DELETE /admin/score_attributes/1.json
  def destroy
    @score_attribute.destroy
    respond_to do |format|
      format.html { redirect_to admin_score_attributes_url, notice: '成绩属性删除成功.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_score_attribute
    @score_attribute = ScoreAttribute.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def score_attribute_params
    params.require(:score_attribute).permit!
  end
end
