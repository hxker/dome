module API
  module V1
    class Users < Grape::API
      include Grape::Kaminari
      resource :users do
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
          optional :max_per_page, type: Integer, default: 100
          optional :offset, type: Integer, default: 0
        end
        get do
          @users = User.all
          render paginate(@users)
        end

        params do
          requires :school_type, type: String, desc: '学校类别'
          requires :district, type: String, desc: '区县'
        end

        get '/school' do
          schools = School.where(status: 1, school_type: params[:school_type], district: params[:district]).select(:id, :name)
          render schools: schools
        end


        params do
          requires :host_year, type: String, desc: '举办年份'
        end
        get '/comp_names' do
          comp_names = Prize.where(host_year: params[:host_year]).select(:name)
          render comp_names: comp_names
        end

        params do
          requires :host_year, type: String, desc: '举办年份'
          requires :comp_name, type: String, desc: '赛事名称'
        end
        get '/comp_prizes' do
          comp_prizes = Prize.where(host_year: params[:host_year], name: params[:comp_name]).select(:id, :prize)
          render comp_prizes: comp_prizes
        end

        params do
          requires :private_token, type: String, desc: 'Private Token'
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
          optional :max_per_page, type: Integer, default: 100
          optional :offset, type: Integer, default: 0
        end
        namespace ':private_token' do
          before do
            authenticate!
          end

          desc '获取用户信息'
          get '/' do
            render user: current_user
          end

          desc '获取用户消息'
          get '/notifications' do
            @unread_notify =current_user.notifications.where(message_type: 6).where(['created_at > ?', Time.now.beginning_of_day])
            render notifications: paginate(@unread_notify), total_num: @unread_notify.count, unread: @unread_notify.unread.count
          end

          desc '更新消息状态为已读'
          params do
            requires :id, type: Integer
          end
          post '/update_notify_read' do
            notify = Notification.find(params[:id])
            if notify.present? && notify.user_id == current_user.id
              if notify.read
                result = [false, '无需更新']
              else
                if notify.update_attributes(read: true)
                  result = [true, '更新成功']
                else
                  result = [false, '更新已读状态失败']
                end
              end
            else
              result = [false, '消息不存在或不是您的消息']
            end
            render result: result
          end

          desc :'获取裁判负责项目'
          get '/user_for_event' do
            events = EventWorker.joins(:event).joins('left join competitions c on c.id=events.competition_id').where(user_id: current_user.id).select(:event_id, 'events.name', 'c.name as comp_name')
            render events: events
          end

          desc '根据队伍'
          params do
            requires :identifier, type: String, desc: '队伍编号'
          end
          get '/team_players' do
            team = Team.joins(:event).joins('INNER JOIN competitions comp ON comp.id = events.competition_id').where(identifier: params[:identifier]).select(:name, :id, 'events.name as event_name', 'events.competition_id as comp_id', 'comp.name as comp_name').take
            if team.present?
              aa = TeamUserShip.joins('INNER JOIN user_profiles up ON up.user_id = team_user_ships.user_id').where(team_id: team.id).select('up.username', 'up.grade', 'up.gender')
              render result: [true, [team_name: team.name, event_name: team.event_name, comp_name: team.comp_name, user: aa]]
            else
              render result: [false, '该队伍编码不存在']
            end
          end
        end

      end
    end
  end
end
