class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    room = Room.find(message_params[:room_id])

    unless room.users.include?(current_user)
      redirect_to root_path and return
    end

    Message.create!(
      content: message_params[:content],
      room: room,
      user: current_user
    )

    redirect_to room_path(room)
  end

  private

  def message_params
    params.require(:message).permit(:content, :room_id)
  end
end
