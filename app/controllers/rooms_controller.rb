class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: :show
  before_action :ensure_room_member, only: :show
  

  #DM一覧
  def index
    # 自分が参加している room 一覧を取得
    @rooms = Room
               .joins(:entries)
               .where(entries: { user_id: current_user.id })
               .distinct
  end

#DM作成、既存DMへの遷移
  def create
    partner = User.find(params[:user_id])

    unless current_user.mutual_follow?(partner)
      redirect_to root_path and return
    end
  #自分と相手が両方参加しているroomを探す
    room = Room
           .joins(:entries)
           .group('rooms.id')
           .having('COUNT(DISTINCT entries.user_id) = 2')
           .where(entries: { user_id: [current_user.id, partner.id] })
           .first

  #なければ新規作成
    if room.nil?
      room = Room.create!
      Entry.create!(user: current_user, room: room)
      Entry.create!(user: partner, room: room)
    end

    redirect_to room_path(room)
  end

  #チャット画面
  def show
    @messages = @room.messages.includes(:user)
    @message = Message.new
    @entries = @room.entries.includes(:user)
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def ensure_room_member
    redirect_to root_path unless @room.users.include?(current_user)
  end
end
