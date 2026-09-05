class TasksController < ApplicationController
  def create
    goal = current_user.goals.find(params[:goal_id])
    task = goal.tasks.new(task_params.merge(user: current_user, plan: goal.plan))
    if task.save
      redirect_to root_path(plan_id: goal.plan_id), notice: "Tarefa adicionada."
    else
      redirect_to root_path(plan_id: goal.plan_id), alert: task.errors.full_messages.to_sentence
    end
  end

  def update
    task = current_user.tasks.find(params[:id])
    params[:completed] == "true" ? task.complete! : task.reopen!
    redirect_to root_path(plan_id: task.plan_id), notice: task.completed_at.present? ? "Tarefa concluída. +25 XP" : "Tarefa reaberta. XP revertido."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path(plan_id: task.plan_id), alert: error.message
  end

  private
    def task_params
      params.require(:task).permit(:title)
    end
end
