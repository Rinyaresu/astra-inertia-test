require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
    sign_in_as(@user)
  end

  test "shows the authenticated dashboard with an active plan workspace" do
    plan = @user.plans.create!(title: "Ciclo de foco", purpose: "Testar", start_date: Date.current, end_date: 1.week.from_now)
    plan.goals.create!(user: @user, title: "Objetivo")
    get root_path
    assert_response :success
    assert_includes response.body, "Dashboard"
    assert_includes response.body, "Ciclo de foco"
  end

  test "cannot access another user's plan" do
    other = User.create!(email_address: "other-#{SecureRandom.hex(3)}@example.com", password: "password")
    plan = other.plans.create!(title: "Privado", start_date: Date.current, end_date: 1.week.from_now)
    get root_path, params: { plan_id: plan.id }
    assert_response :success
    refute_includes response.body, "Privado"
  end
end
