require "application_system_test_case"

class DevelopmentJourneyTest < ApplicationSystemTestCase
  test "a development journey preserves forms and balances XP without reloading" do
    visit new_registration_path
    fill_in "E-mail", with: "journey-#{SecureRandom.hex(4)}@example.test"
    fill_in "Senha", with: "Journey-password-2026"
    fill_in "Confirme sua senha", with: "Journey-password-2026"
    click_on "Criar minha conta"
    click_on "Criar meu primeiro plano"
    within ".modal" do
      fill_in "Nome do plano", with: "Aprender backend"
      set_date "start_date", "2026-09-01"
      set_date "end_date", "2026-08-01"
      click_on "Criar plano"
      assert_text "deve ser depois do início"
      assert_field "Nome do plano", with: "Aprender backend"
      set_date "end_date", "2026-12-01"
      click_on "Criar plano"
    end
    assert_no_selector ".modal"
    assert_text "01/09/2026 — 01/12/2026"
    fill_in "Título do objetivo", with: "Entender transações"
    click_on "Adicionar objetivo"
    fill_in "Nova tarefa para Entender transações", with: "Praticar locks"
    click_on "Adicionar tarefa"
    click_on "Concluir Praticar locks"
    within(".xp-badge") { assert_text "25 XP" }
    click_on "Reabrir Praticar locks"
    within(".xp-badge") { assert_text "0 XP" }
    click_on "Concluir Praticar locks"
    within(".xp-badge") { assert_text "25 XP" }
    find("textarea").fill_in with: "Aprendi como proteger uma transação."
    click_on "Salvar check-in"
    assert_text "Aprendi como proteger uma transação."
    perform_enqueued_jobs(only: ExportPlanJob) { click_on "Gerar XLSX"; assert_text "Seu relatório está sendo preparado" }
    assert_link "Baixar relatório", exact: false, wait: 10
    click_on "Sair"
    assert_text "Bem-vindo de volta."
  end

  private
    def set_date(name, value)
      # Selenium's locale-dependent date typing does not reliably fire React's change event.
      execute_script <<~JS, find("input[name='#{name}']"), value
        Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set.call(arguments[0], arguments[1]);
        arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
      JS
    end
end
