class CheckInsController < ApplicationController
  def create
    plan = current_user.plans.find(params[:plan_id])
    check_in = plan.check_ins.new(check_in_params.merge(user: current_user, checked_in_on: Date.current))
    if check_in.save
      redirect_to root_path(plan_id: plan.id), notice: "Check-in salvo. Obrigado por olhar para o caminho."
    else
      redirect_to root_path(plan_id: plan.id), alert: check_in.errors.full_messages.to_sentence
    end
  end

  private
    def check_in_params
      params.require(:check_in).permit(:reflection)
    end
end
