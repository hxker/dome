class VolunteersController < ApplicationController
  before_action :require_user, except: [:index, :show]


  def index
    @volunteers = Volunteer.all.page(params[:page]).per(params[:per])
  end

  def show
    @volunteer = Volunteer.find(params[:id])
    if current_user.present?
      @already_apply = CompWorker.where(user_id: current_user.id, competition_id: params[:id]).exists?
    end
  end

  def apply_require
    unless require_email_and_mobile
      flash[:notice]='申请志愿者身份时 手机和邮箱都要验证'
    end
    redirect_to '/volunteers/'+params[:id]
  end

  def apply_comp_volunteer
    if require_email_and_mobile
      username = params[:username]
      school = params[:school].to_i
      age= params[:age].to_i
      grade= params[:grade]
      if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
        result = [false, '姓名为2-4位中文']
      else
        if username.present? && school !=0 && age != 0 && grade.present? && current_user.user_profile.update_attributes!(username: username, school: school, age: age, grade: grade)
          if params[:comp_id].present?
            cw = CompWorker.where(competition_id: params[:comp_id], user_id: current_user.id).exists?
            if cw
              result=[false, '您已经申请']
            else
              comp_worker = CompWorker.create!(competition_id: params[:comp_id], user_id: current_user.id)
              if comp_worker.save
                result=[true, '申请成功,等待审核']
              else
                result=[false, '申请失败']
              end
            end
          else
            result=[false, '参数不完整']
          end
        else
          result=[false, '个人信息填写不规范']
        end
      end
    else
      result=[false, '手机和邮箱您还未验证']
    end
    render json: result
  end
end
