require "test_helper"

class PlanTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @plan = @user.plans.create!(title: "Primeiro ciclo", purpose: "Crescer com foco", start_date: Date.current, end_date: 30.days.from_now.to_date)
    @goal = @plan.goals.create!(title: "Ship beta", user: @user)
    @task = @goal.tasks.create!(title: "Invite users", user: @user, plan: @plan)
  end

  test "has derived progress" do
    assert_equal 0, @plan.progress
    @task.update!(completed_at: Time.current)
    assert_equal 100, @plan.reload.progress
  end

  test "stale task instances cannot award or reverse XP twice" do
    stale = Task.find(@task.id)
    @task.complete!
    stale.complete!
    assert_equal 25, @user.xp_total
    assert_equal 1, @task.xp_entries.count

    stale = Task.find(@task.id)
    @task.reopen!
    stale.reopen!
    assert_equal 0, @user.xp_total
    assert_equal 2, @task.xp_entries.count
  end

  test "completion awards XP once and reopening reverses it" do
    @task.complete!
    assert_equal 25, @user.xp_total
    @task.reopen!
    assert_equal 0, @user.reload.xp_total
    assert_equal %w[completion reversal], @task.xp_entries.order(:created_at).pluck(:kind)
    assert @task.xp_entries.all?(&:signature_valid?)
  end
end
