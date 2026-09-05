class GoalsController < ApplicationController
  def create
    plan = current_user.plans.find(params[:plan_id])
    goal = plan.goals.new(goal_params.merge(user: current_user))
    if goal.save
      redirect_to root_path(plan_id: plan.id), notice: "Objetivo adicionado."
    else
      redirect_to root_path(plan_id: plan.id), alert: goal.errors.full_messages.to_sentence
    end
  end

  def update
    goal = current_user.goals.find(params[:id])
    if goal.update(goal_params)
      redirect_to root_path(plan_id: goal.plan_id), notice: "Objetivo atualizado."
    else
      redirect_to root_path(plan_id: goal.plan_id), alert: goal.errors.full_messages.to_sentence
    end
  end

  private
    def goal_params
      params.require(:goal).permit(:title, :description, :due_date)
    end
end
