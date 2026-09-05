require "test_helper"

class ExportPlanJobTest < ActiveJob::TestCase
  setup do
    @user = users(:one)
    @plan = @user.plans.create!(title: "Relatório", purpose: "Testar", start_date: Date.current, end_date: 1.week.from_now)
    @export = @user.exports.create!(plan: @plan)
  end

  test "creates a ready workbook with the five product sheets" do
    ExportPlanJob.perform_now(@export.id, @plan.id)
    assert @export.reload.ready?
    assert File.exist?(@export.file_path)
    assert_operator File.size(@export.file_path), :>, 100
    Zip::File.open(@export.file_path) do |zip|
      workbook = Nokogiri::XML(zip.read("xl/workbook.xml"))
      assert_equal [ "Visão geral", "Objetivos", "Tarefas", "XP", "Check-ins" ], workbook.remove_namespaces!.xpath("//sheet").map { |sheet| sheet["name"] }
      overview = Nokogiri::XML(zip.read("xl/worksheets/sheet1.xml"))
      assert_includes overview.text, "Ativo"
      assert_includes overview.text, "XP acumulado"
    end
  ensure
    File.delete(@export.file_path) if @export&.file_path && File.exist?(@export.file_path)
  end
end
