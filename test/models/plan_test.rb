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

  test "completion awards XP once and reopening reverses it" do
    @task.complete!
    assert_equal 25, @user.xp_total
    @task.reopen!
    assert_equal 0, @user.reload.xp_total
    assert_equal %w[completion reversal], @task.xp_entries.order(:created_at).pluck(:kind)
    assert @task.xp_entries.all?(&:signature_valid?)
  end
end
