class ExportsController < ApplicationController
  def create
    plan = current_user.plans.find(params[:plan_id])
    export = current_user.exports.create!(plan: plan, status: "queued")
    ExportPlanJob.perform_later(export.id, plan.id)
    redirect_to root_path(plan_id: plan.id), notice: "Seu relatório está sendo preparado em segundo plano."
  end

  def download
    export = current_user.exports.find(params[:id])
    return redirect_to root_path, alert: "Relatório ainda não está pronto." unless export.ready? && export.file_path.present? && File.exist?(export.file_path)
    send_file export.file_path, filename: "pdi-#{export.id}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: "attachment"
  end
end
