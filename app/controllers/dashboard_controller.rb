class DashboardController < ApplicationController
  def index
    plans = current_user.plans.includes(goals: :tasks).order(start_date: :desc, created_at: :desc)
    selected = plans.find_by(id: params[:plan_id]) || plans.first
    render inertia: "Dashboard", props: {
      user: { email: current_user.email_address, xp: current_user.xp_total, level: current_user.level },
      plans: plans.map { |plan| plan_json(plan) },
      active_plan: selected && plan_json(selected, include_details: true),
      recent_xp: current_user.xp_entries.includes(:task, :plan).order(created_at: :desc).limit(8).map { |entry| xp_json(entry) }
    }
  end

  private
    def plan_json(plan, include_details: false)
      data = { id: plan.id, title: plan.title, purpose: plan.purpose, start_date: plan.start_date, end_date: plan.end_date, status: plan.status, progress: plan.progress, task_count: plan.tasks.size, completed_tasks: plan.completed_tasks }
      return data unless include_details
      data.merge(
        goals: plan.goals.map { |goal| { id: goal.id, title: goal.title, description: goal.description, due_date: goal.due_date, tasks: goal.tasks.map { |task| task_json(task) } } },
        check_ins: plan.check_ins.order(checked_in_on: :desc).limit(5).map { |check| { id: check.id, reflection: check.reflection, checked_in_on: check.checked_in_on } },
        exports: plan.exports.where(user: current_user).order(created_at: :desc).limit(3).map { |export| { id: export.id, status: export.status, created_at: export.created_at, download_url: export.ready? ? download_export_path(export) : nil } }
      )
    end

    def task_json(task)
      { id: task.id, title: task.title, completed: task.completed_at.present?, completed_at: task.completed_at }
    end

    def xp_json(entry)
      { id: entry.id, points: entry.points, kind: entry.kind, task_title: entry.task.title, plan_title: entry.plan.title, created_at: entry.created_at }
    end
end
