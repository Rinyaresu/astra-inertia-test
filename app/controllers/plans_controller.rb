class PlansController < ApplicationController
  def create
    plan = current_user.plans.new(plan_params)
    if plan.save
      redirect_to root_path(plan_id: plan.id), notice: "Plano criado. Vamos avançar um passo de cada vez."
    else
      redirect_to root_path, alert: plan.errors.full_messages.to_sentence
    end
  end

  def update
    plan = current_user.plans.find(params[:id])
    if plan.update(plan_params)
      redirect_to root_path(plan_id: plan.id), notice: "Plano atualizado."
    else
      redirect_to root_path(plan_id: plan.id), alert: plan.errors.full_messages.to_sentence
    end
  end

  private
    def plan_params
      params.require(:plan).permit(:title, :purpose, :start_date, :end_date, :status)
    end
end
