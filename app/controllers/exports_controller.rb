class ExportsController < ApplicationController
  def create
    plan = current_user.plans.find(params[:plan_id])
    export = current_user.exports.create!(plan: plan, status: "queued")
    ExportPlanJob.perform_later(export.id, plan.id)
    redirect_to root_path(plan_id: plan.id), notice: "Seu relatório está sendo preparado em segundo plano."
  end

  def download
    export_id = params[:id].to_i
    export = current_user.exports.find(export_id)
    path = Rails.root.join("storage", "exports", "#{export_id}.xlsx")
    return redirect_to root_path, alert: "Relatório ainda não está pronto." unless export.ready? && export.file_path == path.to_s && File.file?(path)
    send_data File.binread(path), filename: "pdi-#{export_id}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: "attachment"
  end
end
