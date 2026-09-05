require "fileutils"

class ExportPlanJob < ApplicationJob
  queue_as :default

  def perform(export_id, plan_id)
    export = Export.find(export_id)
    plan = export.user.plans.includes(goals: :tasks).find(plan_id)
    export.update!(status: "processing")
    directory = Rails.root.join(Rails.env.test? ? "tmp/storage" : "storage", "exports")
    FileUtils.mkdir_p(directory)
    path = directory.join("#{export.id}.xlsx")
    package = Axlsx::Package.new
    workbook = package.workbook
    title = workbook.styles.add_style(b: true, fg_color: "FFFFFF", bg_color: "234E52", alignment: { horizontal: :center })
    header = workbook.styles.add_style(b: true, fg_color: "FFFFFF", bg_color: "4D7C78")
    workbook.add_worksheet(name: "Visão geral") do |sheet|
      sheet.add_row [ "PDI — #{plan.title}" ], style: title
      sheet.add_row [ "Propósito", plan.purpose ]
      sheet.add_row [ "Período", "#{plan.start_date} a #{plan.end_date}" ]
      sheet.add_row [ "Status", { "active" => "Ativo", "paused" => "Em pausa", "completed" => "Concluído" }.fetch(plan.status) ]
      sheet.add_row [ "XP acumulado", plan.xp_entries.sum(:points) ]
      sheet.add_row [ "Gerado em", Time.current.strftime("%d/%m/%Y %H:%M %Z") ]
      sheet.add_row [ "Progresso", "#{plan.progress}%" ]
      sheet.add_row [ "Tarefas concluídas", "#{plan.completed_tasks}/#{plan.tasks.size}" ]
    end
    workbook.add_worksheet(name: "Objetivos") do |sheet|
      sheet.add_row [ "Objetivo", "Descrição", "Prazo", "Tarefas", "Concluídas" ], style: header
      plan.goals.each { |goal| sheet.add_row [ goal.title, goal.description, goal.due_date, goal.tasks.size, goal.tasks.where.not(completed_at: nil).count ] }
    end
    workbook.add_worksheet(name: "Tarefas") do |sheet|
      sheet.add_row [ "Objetivo", "Tarefa", "Status", "Concluída em" ], style: header
      plan.goals.each { |goal| goal.tasks.each { |task| sheet.add_row [ goal.title, task.title, task.completed_at ? "Concluída" : "Aberta", task.completed_at ] } }
    end
    workbook.add_worksheet(name: "XP") do |sheet|
      sheet.add_row [ "Data", "Tarefa", "Tipo", "XP" ], style: header
      plan.xp_entries.includes(:task).order(:created_at).each { |entry| sheet.add_row [ entry.created_at, entry.task.title, entry.kind == "completion" ? "Conclusão" : "Reversão", entry.points ] }
    end
    workbook.add_worksheet(name: "Check-ins") do |sheet|
      sheet.add_row [ "Data", "Reflexão" ], style: header
      plan.check_ins.order(:checked_in_on).each { |check| sheet.add_row [ check.checked_in_on, check.reflection ] }
    end
    workbook.worksheets.each do |sheet|
      sheet.sheet_view.pane do |pane|
        pane.top_left_cell = "A2"
        pane.y_split = 1
        pane.state = :frozen
      end
      sheet.column_widths(*Array.new(sheet.rows.first.cells.size, 28))
    end
    package.serialize(path.to_s)
    export.update!(status: "ready", file_path: path.to_s)
  rescue StandardError => error
    export&.update(status: "failed", error_message: error.message)
    raise
  end
end
