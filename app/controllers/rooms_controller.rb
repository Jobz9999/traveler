class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_room_member, only: :show

  #DM一覧
  def index
    @rooms = Room
       @rooms = current_user.rooms.includes(entries: :user)
  end

  #DM作成、既存DMへの遷移
  def create
    partner = User.find(params[:user_id])

    unless current_user.mutual_follow?(partner)
      redirect_to root_path and return
    end

    room = current_user.rooms
                       .joins(:entries)
                       .where(entries: { user_id: partner.id })
                       .first

    if room.nil?
      room = Room.create!
      Entry.create!(user: current_user, room: room)
      Entry.create!(user: partner, room: room)
    end

    redirect_to room_path(room)
  end

  #チャット画面
  def show
    @room = Room.find(params[:id])
    @messages = @room.messages.includes(:user)
    @message = Message.new
    @entries = @room.entries.includes(:user)
  end

  private

  def ensure_room_member
    room = Room.find(params[:id])
    redirect_to root_path unless room.users.include?(current_user)
  end
end
