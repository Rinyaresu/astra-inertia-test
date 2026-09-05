require "test_helper"

class ProductActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
    @plan = @user.plans.create!(title: "Ciclo", start_date: Date.current, end_date: 1.week.from_now)
    @goal = @plan.goals.create!(user: @user, title: "Objetivo")
    sign_in_as(@user)
  end

  test "creates a goal, task and check-in in the selected plan" do
    assert_difference -> { @plan.goals.count }, 1 do
      post plan_goals_path(@plan), params: { goal: { title: "Novo objetivo" } }
    end
    assert_redirected_to root_path(plan_id: @plan.id)

    assert_difference -> { @goal.tasks.count }, 1 do
      post goal_tasks_path(@goal), params: { task: { title: "Primeiro passo" } }
    end
    assert_redirected_to root_path(plan_id: @plan.id)

    assert_difference -> { @plan.check_ins.count }, 1 do
      post plan_check_ins_path(@plan), params: { check_in: { reflection: "Aprendi a começar pequeno." } }
    end
    assert_redirected_to root_path(plan_id: @plan.id)
  end

  test "completion and reopening produce a balanced XP history" do
    task = @goal.tasks.create!(user: @user, plan: @plan, title: "Passo")
    patch task_path(task), params: { completed: "true" }
    patch task_path(task), params: { completed: "false" }
    assert_equal 0, @user.reload.xp_total
    assert_equal %w[completion reversal], task.xp_entries.order(:created_at).pluck(:kind)
  end

  test "export is queued and cannot be downloaded by another user" do
    assert_enqueued_with(job: ExportPlanJob) do
      post plan_exports_path(@plan)
    end
    export = @user.exports.order(:created_at).last
    assert export.queued?

    other = User.create!(email_address: "intruder-#{SecureRandom.hex(3)}@example.com", password: "password")
    sign_in_as(other)
    get download_export_path(export)
    assert_response :not_found
  end
end
