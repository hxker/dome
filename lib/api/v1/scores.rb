module API
  module V1
    class Scores < Grape::API
      resources :scores do
        desc '获取成绩属性'
        params do
          optional :except, type: String
        end
        get '/' do
          except = params[:except].present? ? params[:except] : 0
          score_attributes = ScoreAttribute.where.not(id: except).select(:id, :name, :write_type)
          render score_attributes: score_attributes
        end
        namespace ':private_token' do
          before do
            authenticate!
          end

          desc '成绩登记'
          params do
            requires :event_id, type: Integer, desc: '项目id'
            requires :schedule_id, type: String, desc: '赛程id'
            requires :kind, type: Integer, desc: '对抗/评分'
            requires :th, type: Integer, desc: '第几场'
            requires :team1_id, type: Integer, desc: '队伍1'
            optional :team2_id, type: Integer, desc: '队伍2'
            requires :score1, type: Hash, desc: '成绩1'
            optional :score2, type: String, desc: '成绩2'
            optional :note, type: String, desc: '备注'
            requires :device_no, type: String, desc: '设备号'
            requires :confirm_sign, type: File, desc: '确认签名'
          end
          post '/score' do
            result = CompetitionService.post_team_scores(params[:event_id], params[:schedule_id], params[:kind], params[:th], params[:team1_id], params[:team2_id], params[:score1], params[:score2], params[:note], params[:device_no], params[:confirm_sign])
            render status: result[0], message: result[1]
          end
        end
      end

    end
  end
end