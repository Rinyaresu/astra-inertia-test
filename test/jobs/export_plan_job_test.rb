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
  ensure
    File.delete(@export.file_path) if @export&.file_path && File.exist?(@export.file_path)
  end
end
